# 🔐 pip-auto-venv (wrapper inteligente para pip en Kali)

Un script inteligente para `pip` en Kali Linux que detecta automáticamente el error común:

> `error: externally-managed-environment`

Cuando lo detecta, te ofrece crear y activar un entorno virtual local en el directorio actual, y reintenta la instalación — tal como debería funcionar.

---

## ✅ Características

- 🧠 Detecta automáticamente el error `externally-managed-environment` en `pip install`
- 🛠️ Ofrece crear y activar un entorno virtual local (`./venv`) si es necesario
- 🔁 Reintenta `pip install` dentro del nuevo entorno virtual
- 🧼 Pasa los demás subcomandos de `pip` sin cambios (`list`, `show`, `uninstall`, etc.)
- 💡 No propone crear venv si ya estás dentro de uno

---

## 🚀 Instalación

1. **Descarga el script del wrapper**

Guarda este archivo como `~/.safe_pip_wrapper.sh`:

```bash
wget -O ~/.safe_pip_wrapper.sh https://raw.githubusercontent.com/NestyF/pip-auto-venv/main/safe_pip_wrapper.sh
chmod +x ~/.safe_pip_wrapper.sh
```

2. **Agrega el alias a tu configuración del shell**

Para **Zsh**:
```bash
echo "alias pip='bash ~/.safe_pip_wrapper.sh'" >> ~/.zshrc
source ~/.zshrc
```

Para **Bash**:
```bash
echo "alias pip='bash ~/.safe_pip_wrapper.sh'" >> ~/.bashrc
source ~/.bashrc
```

---

## 📜 Código del Script

```bash
#!/bin/bash

# Detectar si ya estamos dentro de un entorno virtual
if [[ -n "$VIRTUAL_ENV" ]]; then
  /usr/bin/pip3 "$@"
  exit $?
fi

# Solo interceptar si se trata de pip install ...
if [[ "$1" == "install" ]]; then
  shift
  TMP_LOG=$(mktemp)

  /usr/bin/pip3 install "$@" 2> "$TMP_LOG"
  EXIT_CODE=$?

  if grep -q "externally-managed-environment" "$TMP_LOG"; then
    echo -e "\n⚠️  Kali detectó un entorno gestionado (externally-managed-environment)."
    read -p "¿Deseas crear y activar un entorno virtual aquí y continuar con la instalación? (s/n): " ans

    if [[ "$ans" =~ ^[Ss]$ ]]; then
      python3 -m venv venv && source venv/bin/activate
      echo "[*] Entorno virtual activado. Reintentando instalación..."
      pip install --upgrade pip
      pip install "$@"
    else
      echo "[!] Instalación cancelada."
      exit 1
    fi
  else
    cat "$TMP_LOG"
  fi

  rm -f "$TMP_LOG"
  exit $EXIT_CODE
else
  /usr/bin/pip3 "$@"
fi
```

---

## 📂 Ejemplo

```bash
pip install impacket
# Si aparece el error: 'externally-managed-environment', el script propondrá crear ./venv y volver a intentar
```

---

## 📘 Licencia

Licencia MIT
