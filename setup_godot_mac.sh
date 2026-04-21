#!/bin/bash

# Скрипт для скачивания Godot Editor с предустановленным модулем Voxel
# Специально для macOS

echo "Скачиваем Godot + Voxel Module (macOS)..."
curl -L -o godot_voxel_mac.zip "https://github.com/Zylann/godot_voxel/releases/download/v1.6/godot.macos.editor.app.zip"

echo "Распаковываем архив..."
unzip -q godot_voxel_mac.zip -d GodotVoxel

echo "Удаляем архив..."
rm godot_voxel_mac.zip

echo ""
echo "=================================================="
echo "ГОТОВО!"
echo "Ваш редактор Godot находится в папке 'GodotVoxel/'."
echo ""
echo "ВАЖНО: macOS может заблокировать запуск скачанного приложения."
echo "Чтобы разрешить запуск:"
echo "1. Откройте папку GodotVoxel в Finder."
echo "2. Нажмите правой кнопкой мыши (или Control+Click) на Godot.app."
echo "3. Выберите 'Открыть' (Open)."
echo "4. В появившемся окне подтвердите запуск."
echo "=================================================="
echo ""
echo "После запуска Godot нажмите 'Import' (Импорт) и выберите файл project.godot из папки godot_plankton_tycoon."
