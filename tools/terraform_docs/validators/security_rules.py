from pathlib import Path
import hcl2

class SecurityValidator:
    def validate(self, module_path: Path) -> list:
        """
        セキュリティルールの検証
        """
        errors = []
        
        # Terraformファイルを解析
        config = self._parse_terraform_files(module_path)
        
        # セキュリティグループのルールをチェック
        errors.extend(self._check_security_groups(config))
        
        # 暗号化設定をチェック
        errors.extend(self._check_encryption(config))
        
        return errors

    def _parse_terraform_files(self, module_path: Path) -> dict:
        config = {}
        for tf_file in module_path.glob('*.tf'):
            with tf_file.open() as f:
                config.update(hcl2.load(f))
        return config

    def _check_security_groups(self, config: dict) -> list:
        errors = []
        for resource_type, resources in config.get('resource', {}).items():
            if resource_type == 'aws_security_group':
                for name, sg_config in resources.items():
                    if 'ingress' in sg_config:
                        for rule in sg_config['ingress']:
                            if rule.get('cidr_blocks') == ['0.0.0.0/0']:
                                errors.append(f"セキュリティグループ '{name}' で全てのIPからのアクセスが許可されています")
        return errors

    def _check_encryption(self, config: dict) -> list:
        errors = []
        for resource_type, resources in config.get('resource', {}).items():
            if resource_type in ['aws_ebs_volume', 'aws_s3_bucket']:
                for name, resource_config in resources.items():
                    if not resource_config.get('encrypted', False):
                        errors.append(f"{resource_type} '{name}' で暗号化が有効になっていません")
        return errors
