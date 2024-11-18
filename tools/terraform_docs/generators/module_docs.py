import hcl2
from pathlib import Path
import yaml

class ModuleDocGenerator:
    def __init__(self):
        self.template_path = Path(__file__).parent.parent / 'templates' / 'module_template.md'

    def generate(self, module_path: Path) -> str:
        """
        引数:
            module_path: Terraformモジュールのディレクトリパス
        戻り値:
            生成されたMarkdownドキュメント
        """
        # Terraformファイルを解析
        config = self._parse_terraform_files(module_path)
        # 変数定義を抽出
        variables = self._extract_variables(config)
        # リソース定義を抽出
        resources = self._extract_resources(config)
        
        # Markdownドキュメントを生成して返す
        return self._generate_markdown(
            module_name=module_path.name,  # モジュール名
            variables=variables,           # 抽出した変数
            resources=resources           # 抽出したリソース
        )

    def _parse_terraform_files(self, module_path: Path) -> dict:
        """
        指定されたディレクトリ内の全ての.tfファイルを解析
        """
        config = {}
        # *.tf にマッチするファイルを全て取得
        for tf_file in module_path.glob('*.tf'):
            with tf_file.open() as f:
                # HCL形式のファイルを解析して辞書に追加
                config.update(hcl2.load(f))
        return config

    def _extract_variables(self, config: dict) -> list:
        """
        Terraform設定から変数定義を抽出
        """
        variables = []
        # 'variable' セクションから変数を取得
        for var_name, var_config in config.get('variable', {}).items():
            variables.append({
                'name': var_name,                           # 変数名
                'type': var_config.get('type', 'any'),      # データ型（デフォルト: any）
                'description': var_config.get('description', ''),  # 説明
                'default': var_config.get('default', None)   # デフォルト値
            })
        return variables

    def _extract_resources(self, config: dict) -> list:
        """
        Terraform設定からリソース定義を抽出
        """
        resources = []
        # 'resource' セクションからリソースを取得
        for resource_type, resource_configs in config.get('resource', {}).items():
            for resource_name, resource_config in resource_configs.items():
                resources.append({
                    'type': resource_type,     # リソースタイプ（例：aws_instance）
                    'name': resource_name,     # リソース名
                    'config': resource_config  # リソースの設定内容
                })
        return resources

    def _generate_markdown(self, module_name: str, variables: list, resources: list) -> str:
        """
        テンプレートを使用してMarkdownドキュメントを生成
        """
        # テンプレートファイルを読み込み
        with self.template_path.open() as f:
            template = f.read()

        # テンプレート内の変数を実際の値で置換
        return template.format(
            module_name=module_name,
            variables=self._format_variables(variables),
            resources=self._format_resources(resources)
        )

    def _format_variables(self, variables: list) -> str:
        """
        変数をMarkdown形式にフォーマット
        """
        if not variables:
            return "変数は定義されていません。"
        
        markdown = "| 名前 | 型 | 説明 | デフォルト値 |\n"
        markdown += "|------|-----|------|-------------|\n"
        
        for var in variables:
            markdown += f"| {var['name']} | {var['type']} | {var['description']} | {var['default']} |\n"
        
        return markdown

    def _format_resources(self, resources: list) -> str:
        """
        リソースをMarkdown形式にフォーマット
        """
        if not resources:
            return "リソースは定義されていません。"
        
        markdown = "| タイプ | 名前 | 説明 |\n"
        markdown += "|--------|------|------|\n"
        
        for resource in resources:
            markdown += f"| {resource['type']} | {resource['name']} | {self._get_resource_description(resource)} |\n"
        
        return markdown

    def _get_resource_description(self, resource: dict) -> str:
        """
        リソースの説明文を生成
        """
        config = resource['config']
        
        # 1. tagsが存在し、かつ辞書型である場合
        if 'tags' in config and isinstance(config['tags'], dict):
            # Descriptionタグを探す（大文字小文字両方）
            description = config['tags'].get('Description') or config['tags'].get('description')
            if description:
                return description
        
        return f"{resource['type']}リソース"