import argparse
from pathlib import Path
from generators.module_docs import ModuleDocGenerator
from generators.diagram_gen import DiagramGenerator
from validators.naming_rules import NamingValidator
from validators.security_rules import SecurityValidator
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TerraformDocsGenerator:
    def __init__(self, modules_path: Path):
        self.modules_path = modules_path
        self.module_doc_generator = ModuleDocGenerator()
        self.diagram_generator = DiagramGenerator()
        self.validators = [
            NamingValidator(),
            SecurityValidator()
        ]

    def generate_docs(self):
        """
        すべてのモジュールのドキュメントを生成
        """
        logger.info(f"ドキュメント生成を開始: {self.modules_path}")
        for module_dir in self.modules_path.iterdir():
            if module_dir.is_dir():
                logger.info(f"モジュール処理中: {module_dir.name}")
                self._process_module(module_dir)
        logger.info("ドキュメント生成が完了しました")

    def _process_module(self, module_dir: Path):
        """
        個別のモジュールの処理
        """
        # バリデーション実行
        validation_errors = []
        for validator in self.validators:
            errors = validator.validate(module_dir)
            if errors:
                validation_errors.extend(errors)

        # ドキュメント生成
        docs = self.module_doc_generator.generate(module_dir)
        diagram = self.diagram_generator.generate(module_dir)

        # モジュールディレクトリ内にドキュメントを出力
        output_file = module_dir / "README.md"
        self._write_documentation(output_file, docs, diagram, validation_errors)

    def _write_documentation(self, output_file: Path, docs: str, 
                          diagram: str, errors: list):
        """
        ドキュメントの書き込み
        """
        with output_file.open('w') as f:
            f.write(docs)
            if diagram:
                f.write("\n## アーキテクチャ図\n\n")
                f.write(diagram)
            if errors:
                f.write("\n## 検証結果\n\n")
                for error in errors:
                    f.write(f"- ⚠️ {error}\n")

def main():
    try:
        parser = argparse.ArgumentParser(description='Terraform documentation generator')
        parser.add_argument('--modules-path', type=Path, default=Path('../../terraform/modules'))
        
        args = parser.parse_args()
        
        if not args.modules_path.exists():
            raise FileNotFoundError(f"モジュールパス '{args.modules_path}' が存在しません")
        
        generator = TerraformDocsGenerator(args.modules_path)
        generator.generate_docs()
        
    except Exception as e:
        print(f"エラーが発生しました: {str(e)}")
        exit(1)

if __name__ == "__main__":
    main()
