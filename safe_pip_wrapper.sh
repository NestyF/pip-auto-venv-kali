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
