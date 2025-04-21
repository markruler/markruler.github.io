# scripts/venv/bin/python scripts/create_post_image.py "일상에서의 SSH" --output _content/images/network/ssh/meta-image.png
from PIL import Image, ImageDraw, ImageFont
import os
import sys

def wrap_text(text, font, max_width):
    words = text.split()
    lines = []
    current_line = []
    current_width = 0

    for word in words:
        word_width = font.getlength(word + ' ')
        if current_width + word_width <= max_width:
            current_line.append(word)
            current_width += word_width
        else:
            if current_line:
                lines.append(' '.join(current_line))
            current_line = [word]
            current_width = word_width

    if current_line:
        lines.append(' '.join(current_line))

    return lines

def create_meta_image(title, author, output_path, scale_output=True):
    # 고해상도 캔버스 (16:9)
    base_width, base_height = 1920, 1080

    background_path = '_content/images/markruler-default-cropped-16x9.png'
    logo_path = '_content/images/logo.png'

    # 배경 이미지 로드 및 크기 조정
    background = Image.open(background_path).convert('RGBA')
    
    # 배경 이미지의 비율 계산
    bg_ratio = background.width / background.height
    canvas_ratio = base_width / base_height
    
    if bg_ratio > canvas_ratio:  # 배경이 더 넓은 경우
        new_height = base_height
        new_width = int(new_height * bg_ratio)
    else:  # 배경이 더 좁은 경우
        new_width = base_width
        new_height = int(new_width / bg_ratio)
    
    background = background.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    # 중앙 정렬을 위한 좌표 계산
    x = (new_width - base_width) // 2
    y = (new_height - base_height) // 2
    
    # 배경 이미지 중앙 부분을 크롭
    background = background.crop((x, y, x + base_width, y + base_height))
    
    # 최종 이미지 생성
    bg_image = Image.new('RGBA', (base_width, base_height), (30, 30, 30, 255))
    bg_image.paste(background, (0, 0))

    # 어두운 오버레이 추가
    overlay = Image.new('RGBA', (base_width, base_height), (0, 0, 0, 128))
    bg_image = Image.alpha_composite(bg_image, overlay)

    logo = Image.open(logo_path).convert('RGBA')
    logo_width = base_width // 8
    logo_height = int(logo.height * (logo_width / logo.width))
    logo = logo.resize((logo_width, logo_height), Image.Resampling.LANCZOS)
    
    # 왼쪽 여백 설정
    left_margin = 80
    logo_x, logo_y = left_margin, 50
    bg_image.paste(logo, (logo_x, logo_y), logo)

    draw = ImageDraw.Draw(bg_image)
    font_title = ImageFont.truetype("scripts/KCC-Hanbit.woff2", size=72)
    font_author = ImageFont.truetype("scripts/KCC-Hanbit.woff2", size=100)

    # 제목 위치 조정
    title_x = left_margin
    title_y = logo_y + logo_height + 40
    line_spacing = 12

    text_color = (255, 255, 255, 255)
    shadow_color = (0, 0, 0, 128)
    shadow_offset = 3

    # 제목의 최대 너비 계산 (좌우 여백 동일하게)
    right_margin = left_margin
    max_text_width = base_width - (left_margin + right_margin)
    title_lines = wrap_text(title, font_title, max_text_width)

    # 저자 이름을 로고 옆에 배치
    author_x = logo_x + logo_width + 30
    author_y = logo_y + (logo_height - font_author.size) // 2
    draw.text((author_x + shadow_offset, author_y + shadow_offset), author, font=font_author, fill=shadow_color)
    draw.text((author_x, author_y), author, font=font_author, fill=text_color)

    # 제목 줄마다 출력 (왼쪽 정렬)
    for i, line in enumerate(title_lines):
        y = title_y + i * (font_title.size + line_spacing)
        draw.text((title_x + shadow_offset, y + shadow_offset), line, font=font_title, fill=shadow_color)
        draw.text((title_x, y), line, font=font_title, fill=text_color)

    # 출력 크기 (예: 1200x630 = Open Graph size)
    if scale_output:
        target_size = (1200, 630)
        bg_image = bg_image.resize(target_size, Image.Resampling.LANCZOS)

    # 테두리 추가
    border_color = (0, 153, 229, 255)  # #0099e5
    border_width = 8
    bordered_image = Image.new('RGBA', (bg_image.width + border_width*2, bg_image.height + border_width*2), border_color)
    bordered_image.paste(bg_image, (border_width, border_width))

    bordered_image.save(output_path, format='PNG')
    print(f"✅ 생성 완료: {output_path}")

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Create a meta image with title and author.')
    parser.add_argument('title', type=str, help='The title text for the image')
    parser.add_argument('-a', '--author', type=str, default='임창수', help='The author name (default: 임창수)')
    parser.add_argument('-o', '--output', type=str, default='meta-image.png', help='The output file path (default: result.png)')
    parser.add_argument('--no-scale', action='store_true', help='Disable scaling down (keep full 1920x1080 size)')

    args = parser.parse_args()

    try:
        create_meta_image(args.title, args.author, args.output, scale_output=not args.no_scale)
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        sys.exit(1)
