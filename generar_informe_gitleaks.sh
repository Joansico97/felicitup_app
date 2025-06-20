#!/bin/bash


# Archivos de Salida
OUTPUT="informe-gitleaks_STD.md"
GITLEAKS_JSON="gitleaks-report_STD.json"
GITLEAKS_SARIF="gitleaks-report-sarif.sarif"

# Archivo de Entrada GitLeaks
INPUT="gitleaks-report_STD.json"

# Ruta base del proyecto (por defecto el directorio actual)
PROJECT_DIR="/Users/jorgeantoniosilvacortes/Desktop/Felicitup/felicitup_app"

echo "🚀 Iniciando escaneo de secretos en el directorio: $PROJECT_DIR"
echo ""

# ----------------------------
# Ejecutar Gitleaks
# ----------------------------

echo "🔍 Ejecutando Gitleaks..."
if ! command -v gitleaks >/dev/null 2>&1; then
  echo "❌ Gitleaks no está instalado. Instálalo con: brew install gitleaks"
  exit 1
fi

gitleaks detect --source="$PROJECT_DIR" --report-format json --report-path="$GITLEAKS_JSON"

gitleaks detect --source="$PROJECT_DIR" --report-format sarif --report-path="$GITLEAKS_SARIF"


if [[ $? -ne 0 ]]; then
  echo "⚠️ Gitleaks terminó con errores."
fi


if [ ! -f "$INPUT" ]; then
  echo "❌ Archivo $INPUT no encontrado. Ejecuta Gitleaks primero."
  exit 1
fi

echo "# Informe de Hallazgos - Gitleaks" > $OUTPUT
echo "_Generado el $(date)_  " >> $OUTPUT
echo >> $OUTPUT


jq -c '.[]' "$INPUT" | while read -r finding; do
  ID=$(echo "$finding" | jq -r '.RuleID // "Desconocido"')
  FILE=$(echo "$finding" | jq -r '.File // "Desconocido"')
  LINE=$(echo "$finding" | jq -r '.StartLine // "?"')
  COMMIT=$(echo "$finding" | jq -r '.Commit // "?"')
  DESC=$(echo "$finding" | jq -r '.Description // "No disponible"')
  SECRET=$(echo "$finding" | jq -r '.Secret // ""' | sed 's/./*/g')
  LINK=$(echo "$finding" | jq -r '.Link // "N/A"')
  AUTHOR=$(echo "$finding" | jq -r '.Author // "?"')
  DATE=$(echo "$finding" | jq -r '.Date // "?"')

  echo "## 🔐 Secreto detectado: $ID" >> $OUTPUT
  echo "- **Archivo:** \`$FILE\`" >> $OUTPUT
  echo "- **Línea:** $LINE" >> $OUTPUT
  echo "- **Commit:** \`$COMMIT\`" >> $OUTPUT
  echo "- **Descripción:** $DESC" >> $OUTPUT
  echo "- **Valor detectado:** \`$SECRET\`" >> $OUTPUT
  echo "- **Autor:** $AUTHOR" >> $OUTPUT
  echo "- **Fecha:** $DATE" >> $OUTPUT
  echo "- **Enlace al código:** [$LINK]($LINK)" >> $OUTPUT
  echo "" >> $OUTPUT
  echo "### 🛠️ Recomendaciones" >> $OUTPUT
  echo "- Revocar o restringir la clave inmediatamente si sigue activa." >> $OUTPUT
  echo "- Eliminarla del código fuente y del historial (Git)." >> $OUTPUT
  echo "- Reemplazar por mecanismos seguros (variables de entorno, secretos en el CI/CD o vaults)." >> $OUTPUT
  echo "- Añadir el archivo a \`.gitignore\` si aplica." >> $OUTPUT
  echo "" >> $OUTPUT
  echo "---" >> $OUTPUT
  echo "" >> $OUTPUT
done

echo "✅ Informe generado: $OUTPUT"


