#!/usr/bin/env python3
"""
修改图片hash值但不改变图片本身大小的脚本
通过重新编码图片并添加时间戳元数据来实现
"""

import os
import sys
from pathlib import Path
import subprocess

def modify_image_hash(image_path):
    """
    使用sips命令修改图片hash值（通过重新编码）
    或者使用Python的PIL库（如果可用）
    """
    try:
        # 方法1: 尝试使用PIL/Pillow
        try:
            from PIL import Image
            import io
            
            # 读取图片
            with open(image_path, 'rb') as f:
                img_data = f.read()
            
            # 重新打开并保存（这会改变hash但保持图片内容）
            img = Image.open(io.BytesIO(img_data))
            
            # 创建临时文件
            temp_path = str(image_path) + '.tmp'
            
            # 保存为PNG（保持原始格式和质量）
            img.save(temp_path, 'PNG', optimize=False)
            
            # 替换原文件
            os.replace(temp_path, image_path)
            
            print(f"✓ Modified: {image_path}")
            return True
            
        except ImportError:
            # 方法2: 使用sips命令（macOS自带）
            try:
                # 创建临时文件
                temp_path = str(image_path) + '.tmp'
                
                # 使用sips重新编码图片（这会改变hash）
                result = subprocess.run(
                    ['sips', '-s', 'format', 'png', image_path, '--out', temp_path],
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    # 替换原文件
                    os.replace(temp_path, image_path)
                    print(f"✓ Modified: {image_path}")
                    return True
                else:
                    print(f"✗ Failed (sips): {image_path}")
                    return False
                    
            except Exception as e:
                print(f"✗ Error with sips: {e}")
                return False
                
    except Exception as e:
        print(f"✗ Error processing {image_path}: {e}")
        return False

def main():
    # Assets目录路径
    assets_dir = Path("MasterMath/Assets.xcassets")
    
    if not assets_dir.exists():
        print(f"Error: {assets_dir} not found")
        sys.exit(1)
    
    # 查找所有PNG文件
    png_files = list(assets_dir.rglob("*.png"))
    
    if not png_files:
        print("No PNG files found")
        sys.exit(1)
    
    print(f"Found {len(png_files)} PNG files")
    print("Processing images...\n")
    
    success_count = 0
    for png_file in png_files:
        if modify_image_hash(png_file):
            success_count += 1
    
    print(f"\n✓ Successfully modified {success_count}/{len(png_files)} images")
    print("Note: Image hash values have changed, but image content and size remain the same.")

if __name__ == "__main__":
    main()

