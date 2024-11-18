locals {
  # decrypted_secret_from_file = var.plain_secret != "" ? trimspace(data.local_file.this[0].content) : ""
  # decrypted_secret_from_result = var.plain_secret == "" ? trimspace(data.external.this[0].result["decrypted_${var.secret_name}"]) : ""
  # decrypted_secret_from_result = var.plain_secret == "" ? trimspace(data.external.this[0].result["decrypted_secret"]) : ""
  decrypted_secret_from_file   = (var.plain_secret != "") ? trimspace(data.local_file.this[0].content) : ""
  decrypted_secret_from_result = (var.plain_secret == "") ? trimspace(data.external.this[0].result["decrypted_secret"]) : ""
  decrypted_secret             = coalesce(local.decrypted_secret_from_file, local.decrypted_secret_from_result)
}

resource "null_resource" "this" {
  triggers = {
    password_change_hash = sha256(jsonencode(var.password_change_indicator))
  }

  provisioner "local-exec" {
    command = <<-EOT
      if [ -n "${var.plain_secret}"]; then
        bash ../../scripts/encrypt_secrets.sh <<< '${jsonencode({
    kms_key_alias = var.kms_key_alias.arn,
    plain_secret  = var.plain_secret,
    aws_profile   = var.aws_profile,
    env           = var.env,
    secret_name   = var.secret_name,
    keep_count    = var.keep_count,
    })}'
      fi

      sleep 3

      if [ -n "${var.plain_secret}" ]; then
        bash ../../scripts/decrypt_secrets.sh <<< '${jsonencode({
    aws_profile = var.aws_profile,
    env         = var.env,
    secret_name = var.secret_name
})}'
      fi
    EOT
}
}

# 以下の data sourceは、depends_on属性によって null_resource作成時のみに、apply後に実行される （※通常のdata sourceは、plan時には実行されるが、意図的に避けている）
# 注意点として、null_resource自体が、引数変更ステータス->引数省略ステータスの時にもトリガーが発動してしまうため、ライフサイクルが一致しない。（※２回目以降の引数省略時は、ステータスが変わらずトリガーされないためライフサイクルが一致する）
# この対策として、null_resource内のif分岐で、引数省略時はprovisionerを実行しないようにしている
# 加えて、以下の data sourceは depends_on属性で、null_resource実行後に実行されることが保証されているので、この引数省略時はともに実行されないため、
# null_resource と以下の data source のライフサイクルが一致している
# さらに、明示的にcount属性も追加しているので、ライフサイクルが一致している
# 補足：時間の節約及び、ミスリードを防止するため。毎回復号処理は実行せず、復号ファイルがあればそれを参照するようにしている

# Read decrypted password file After terraform apply
data "local_file" "this" {
  depends_on = [null_resource.this]
  count      = (var.plain_secret != "") ? 1 : 0
  filename   = "${var.cred_dir}/${var.cred_file}"
}

# 以下の external で復号処理が必要なケースについて：
# git clone した場合に、".encrypted_{text}"ファイルは存在するものの、".decrypted_{text}"ファイルは存在しない
# その為、明示的に最新の、".encrypted_{text}"ファイルから、復号するために、復号スクリプトを実行することが必須となる
# 復号スクリプト実行後は、ローカルに復号ファイルが作成される
#
# countで引数省略時のみ作成するようにしている理由：
# 簡潔に言うと、data sourceの評価順序が原因で引数入力時に意図しない挙動となるため。
# 詳細解説：
# 通常data sourceの評価タイミングはplan実行時なので、"引数入力時"においては
# plan時点の暗号ファイルから復号し、リソースを作成したのち、暗号ファイルを引数入力の値で更新することになる。
# つまり、リソースは古い値のまま、暗号ファイルのみ新しい値になるという挙動となってしまう。
# そのため、明示的にcountで"引数省略時"のみ実行されるようにしている

data "external" "this" {
  count   = (var.plain_secret == "") ? 1 : 0
  program = ["bash", "../../scripts/decrypt_secrets.sh"]
  query = {
    aws_profile = var.aws_profile
    env         = var.env
    secret_name = var.secret_name
  }
}