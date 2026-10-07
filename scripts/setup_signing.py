#!/usr/bin/env python3
"""Create a local release key once. Never print secrets or commit signing material."""
import os
from pathlib import Path
import secrets
import subprocess

root = Path(__file__).resolve().parent.parent
private = Path.home() / '.config' / 'receiptflow-signing'
private.mkdir(parents=True, exist_ok=True, mode=0o700)
key = private / 'release.jks'
password_file = private / 'password'
properties = root / 'android' / 'key.properties'
if not key.exists():
    if password_file.exists():
        raise SystemExit('Password already exists without a key. Inspect private signing directory first.')
    password = secrets.token_urlsafe(32)
    password_file.write_text(password)
    password_file.chmod(0o600)
    env = dict(os.environ, RECEIPTFLOW_KEY_PASSWORD=password)
    subprocess.run(['keytool', '-genkeypair', '-v', '-keystore', str(key), '-alias', 'receiptflow',
        '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000', '-storetype', 'JKS',
        '-storepass:env', 'RECEIPTFLOW_KEY_PASSWORD', '-keypass:env', 'RECEIPTFLOW_KEY_PASSWORD',
        '-dname', 'CN=ReceiptFlow, OU=Mobile Project, O=ReceiptFlow, C=VN'], env=env, check=True,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    key.chmod(0o600)
password = password_file.read_text().strip()
properties.write_text(f'storeFile={key}\nstorePassword={password}\nkeyAlias=receiptflow\nkeyPassword={password}\n')
properties.chmod(0o600)
print('Release signing configured. Keep ~/.config/receiptflow-signing backed up privately.')
