# 🗑️ Instrucciones para Limpiar Recursos AWS Existentes

## Por qué
Los recursos ya fueron creados manualmente. Terraform intenta crearlos nuevamente y entra en conflicto. Necesitamos destruirlos para que Terraform los maneje desde cero.

## Pasos (orden importa ⚠️)

### 1. ⏹️ Destruir Auto Scaling Group
1. Consola AWS → **EC2** → **Auto Scaling Groups**
2. Busca `hola-asg`
3. **Actions** → **Delete**
4. Confirmá y **espera** a que termine (las instancias se terminarán automáticamente)
   - ⏱️ Esto tarda 2-3 minutos

### 2. 🔌 Destruir Load Balancer
1. Consola AWS → **EC2** → **Load Balancers**
2. Busca `hola-alb`
3. **Actions** → **Delete**
4. Confirmá

### 3. 🎯 Destruir Target Group
1. Consola AWS → **EC2** → **Target Groups**
2. Busca `hola-tg`
3. **Actions** → **Delete**
4. Confirmá

### 4. 🔐 Destruir Security Groups
1. Consola AWS → **EC2** → **Security Groups**
2. Busca y selecciona `hola-alb-sg`
3. **Actions** → **Delete security group**
4. Confirmá
5. Repite para `hola-ec2-sg`

### 5. 🚀 Verificar que todo fue borrado
- EC2 → Instances: NO debe haber instancias con tag `hola-instance`
- Load Balancers: Vacío
- Target Groups: Vacío
- Security Groups: `hola-alb-sg` y `hola-ec2-sg` no existen

---

## Siguientes pasos (después de limpiar)

### 1️⃣ Configura Secrets en GitHub

Abre: https://github.com/arielguerron14/recuperacion/settings/secrets/actions

Crea estos 4 Secrets (haz clic en **New repository secret** 4 veces):

| Nombre | Valor |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | Tu access key de AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Tu secret key de AWS Academy |
| `AWS_SESSION_TOKEN` | Tu session token (si tienes credenciales temporales) |
| `AWS_REGION` | `us-east-1` |

**Dónde obtener las credenciales:**
- Abre AWS Academy → **Learner Lab** → **Details** → **AWS CLI** → **Copy**
- Te dará un JSON con las 3 credenciales

### 2️⃣ Dispara el Workflow

Ejecuta en PowerShell:
```powershell
cd C:\Users\ariel\Escritorio\recuperacion
git commit --allow-empty -m "ci: rebuild with clean state"
git push origin main
```

Esto disparará el workflow "Deploy to AWS Academy" automáticamente.

### 3️⃣ Monitorea la ejecución

Abre: https://github.com/arielguerron14/recuperacion/actions

Verás la ejecución en tiempo real. Espera a que termine (3-5 minutos).

### 4️⃣ Verifica que funciona

Una vez que el workflow termine exitosamente:

1. Consola AWS → **Load Balancers** → `hola-alb`
2. Copia el **DNS Name** (algo como `hola-alb-40529958.us-east-1.elb.amazonaws.com`)
3. Abre en tu navegador: `http://hola-alb-XXXX.us-east-1.elb.amazonaws.com`
4. Deberías ver: **"Hola Mundo desde Docker en AWS"** ✅

### 5️⃣ Finalizar

Una vez que verificaste que funciona:
- **AWS Academy** → **End Lab**

---

## ⚠️ Notas importantes

- **El orden importa**: ASG primero, luego ALB, luego TG, luego SGs.
- **Espera a que cada paso termine** antes de pasar al siguiente.
- Si algo falla, revisa permisos en AWS Academy (puede haber restricciones).
- Los Secrets son permanentes; no necesitas repetir este paso.

---

## Si algo sale mal

Si después de limpiar y ejecutar Terraform sigue fallando:
1. Verifica que los Secrets están correctos (Settings → Secrets → revisa que están ahí).
2. Revisa el log del workflow (Actions → último run → haz clic en "Deploy to AWS Academy").
3. Busca el error específico en el log y reporta aquí.
