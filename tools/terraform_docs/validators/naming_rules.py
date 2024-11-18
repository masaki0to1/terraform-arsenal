from pathlib import Path
import re
import hcl2

class NamingValidator:
    def __init__(self):
        self.rules = {
            'module_name': r'^[a-z][a-z0-9_]*$',
            'variable_name': r'^[a-z][a-z0-9_]*$',
            'resource_name': r'^[a-z][a-z0-9_]*$'
        }

    def validate(self, module_path: Path) -> list:
        """
        命名規則の検証
        """
        errors = []
        
        # モジュール名の検証
        if not re.match(self.rules['module_name'], module_path.name):
            errors.append(f"モジュール名 '{module_path.name}' が命名規則に違反しています")
        
        # Terraformファイルを解析
        config = self._parse_terraform_files(module_path)
        
        # 変数名の検証
        for var_name in config.get('variable', {}):
            if not re.match(self.rules['variable_name'], var_name):
                errors.append(f"変数名 '{var_name}' が命名規則に違反しています")
        
        # リソース名の検証
        for resource_type, resources in config.get('resource', {}).items():
            for resource_name in resources:
                if not re.match(self.rules['resource_name'], resource_name):
                    errors.append(f"リソース名 '{resource_name}' が命名規則に違反しています")
        
        return errors

    def _parse_terraform_files(self, module_path: Path) -> dict:
        """
        Terraformファイルの解析
        """
        config = {}
        for tf_file in module_path.glob('*.tf'):
            with tf_file.open() as f:
                config.update(hcl2.load(f))
        return config
