# -*- mode: python ; coding: utf-8 -*-
import sys
import os

# Calea către scriptul tău principal
script_path = 'mp3-to-text-v57.py'

# Găsește whisper assets simplu
whisper_datas = []
try:
    import whisper
    whisper_path = os.path.dirname(whisper.__file__)
    assets_path = os.path.join(whisper_path, 'assets')
    
    if os.path.exists(assets_path):
        print(f"Găsit whisper assets: {assets_path}")
        whisper_datas = [(assets_path, 'whisper/assets')]
    else:
        print("Nu s-au găsit whisper assets")
except Exception as e:
    print(f"Eroare la găsirea whisper assets: {e}")

a = Analysis(
    [script_path],
    pathex=[],
    binaries=[],
    datas=[
        # Config
        ('config.yaml', '.') if os.path.exists('config.yaml') else None,
    ] + whisper_datas,
    hiddenimports=[
        'whisper',
        'whisper.model',
        'whisper.audio', 
        'whisper.decoding',
        'whisper.tokenizer',
        'whisper.normalizers',
        'whisper.normalizers.english',
        'whisper.normalizers.basic',
        'srt',
        'yaml',
        'tqdm',
        'rich',
        'tkinter',
        'tkinter.ttk',
        'tkinter.filedialog', 
        'tkinter.scrolledtext',
        'multiprocessing',
        'concurrent.futures',
        'urllib.request',
        'torch',
        'numpy',
        'time',
        'shutil',
        'pkg_resources',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'matplotlib',
        'pandas', 
        'scipy',
        'PIL',
        'cv2',
        'tensorflow',
        'keras',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=None,
    noarchive=False,
)

# Filtrează None-uri
a.datas = [item for item in a.datas if item is not None]

pyz = PYZ(a.pure, a.zipped_data, cipher=None)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='MP3-Transcriber-v57',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='icon.ico' if os.path.exists('icon.ico') else None,
)