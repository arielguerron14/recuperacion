# Configurar GitHub Secrets para AWS Deployment

## Paso 1: Ir a GitHub Secrets

1. Ve a tu repositorio: https://github.com/arielguerron14/recuperacion
2. Click en **Settings** (esquina superior derecha)
3. En el menú izquierdo, ve a **Secrets and variables** → **Actions**

## Paso 2: Agregar los 4 Secrets

Click en **New repository secret** y crea estos 4 secrets:

### Secret 1: AWS_ACCESS_KEY_ID
- **Name:** `AWS_ACCESS_KEY_ID`
- **Value:** Tu Access Key ID de AWS Academy (ej: `ASIAXXXXXXXXXXXXXXXX`)
- Click **Add secret**

### Secret 2: AWS_SECRET_ACCESS_KEY
- **Name:** `AWS_SECRET_ACCESS_KEY`
- **Value:** Tu Secret Access Key de AWS Academy
- Click **Add secret**

### Secret 3: AWS_SESSION_TOKEN
- **Name:** `AWS_SESSION_TOKEN`
- **Value:** Tu Session Token temporal de AWS Academy (si lo tienes; algunos ambientes no lo requieren)
- Click **Add secret**

### Secret 4: AWS_REGION
- **Name:** `AWS_REGION`
- **Value:** `us-east-1`
- Click **Add secret**

## Paso 3: Verificar que los Secrets están creados

Deberías ver 4 secrets listados en la página de Secrets.

## Paso 4: Triggerear el Deployment

Una vez que los secrets estén guardados, ejecuta en local:

```powershell
cd C:\Users\ariel\Escritorio\recuperacion
git commit --allow-empty -m "trigger: deploy via GitHub Actions"
git push origin main
```

El workflow se ejecutará automáticamente. Puedes ver el progreso en:
- Tu repositorio → **Actions** → Ver el workflow corriendo

## ¿Dónde obtener tus credenciales AWS Academy?

En la consola de AWS Academy:

1. Click en **AWS Details** (botón arriba a la derecha)
2. Click en **Copy** para copiar las credenciales
3. Tendrás algo como:
   ```
   export AWS_ACCESS_KEY_ID=ASIA...
   export AWS_SECRET_ACCESS_KEY=...
   export AWS_SESSION_TOKEN=...
   ```

Usa esos valores en los secrets correspondientes.

## Monitorear el Deployment

Después de hacer push:

1. Ve a tu repositorio en GitHub
2. Click en **Actions**
3. Verás el workflow corriendo (puede tomar 2-3 minutos)
4. Cuando termine, las instancias EC2 estarán siendo creadas en AWS Academy

## Verificar que funcionó

En AWS Academy Console:
- Ve a **EC2 → Instances**
- Deberías ver 2 instancias nuevas con nombre `hola-instance`
- Espera 3-5 minutos a que levanten y el Target Group muestre "Healthy"

¡Listo! 🚀
