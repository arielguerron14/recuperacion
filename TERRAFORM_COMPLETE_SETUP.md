# Terraform Complete Infrastructure Setup Guide

## 📋 Archivos Nuevos Creados

Se han generado 6 archivos Terraform profesionales y listos para producción:

### 1. `main_complete.tf` (430+ líneas)
**Contenido:**
- VPC con Internet Gateway
- Subnets públicas en 3 AZs (configurable)
- Route Tables y asociaciones
- Security Groups para ALB y EC2 (HTTP/HTTPS/SSH)
- Application Load Balancer
- Target Group con health checks
- ALB Listener (HTTP puerto 80)
- Launch Template con User Data
- Auto Scaling Group (min, max, desired configurable)
- Data sources para obtener IPs de instancias

### 2. `variables_complete.tf` (95+ líneas)
**Variables disponibles:**
- `region`: Región AWS (default: us-east-1)
- `app_name`: Nombre de la aplicación
- `vpc_cidr`: CIDR de la VPC
- `public_subnet_cidrs`: CIDR de subnets (3 subnets)
- `availability_zones`: AZs para subnets
- `instance_type`: Tipo de instancia (default: t3.micro)
- `asg_min_size`, `asg_max_size`, `asg_desired_capacity`: Escalado automático
- `container_port`: Puerto del contenedor (default: 3000)
- `github_repo_url`: URL del repositorio GitHub
- `common_tags`: Tags comunes para todos los recursos

### 3. `outputs_complete.tf` (180+ líneas)
**Outputs disponibles:**
- VPC ID y Subnet IDs
- ALB DNS Name y ARN
- Target Group ARN y nombre
- ASG nombre, ID y configuración
- Instance IDs, IPs públicas, IPs privadas
- URL de la aplicación
- Security Group IDs
- Launch Template ID y versión
- AMI ID y nombre
- Resumen del deployment

### 4. `user_data_complete.sh.tpl` (85+ líneas)
**Funcionalidad:**
- Actualización del sistema (yum update)
- Instalación de Docker
- Espera 60 segundos para que Docker esté listo
- Instalación de Git
- Clonación del repositorio GitHub
- Build de la imagen Docker
- Ejecución del contenedor con puerto mapeado (80:container_port)
- Logs y verificación

### 5. `backend.tf` (13 líneas)
**Contenido:**
- Configuración de backend local (default)
- Comentarios para backend remoto en S3 (para producción)

### 6. `terraform.tfvars.example` (35 líneas)
**Contenido:**
- Ejemplo de archivo de variables
- Copiar a `terraform.tfvars` y editar según sea necesario

### 7. `README_TERRAFORM.md` (350+ líneas)
**Contenido:**
- Guía completa de Terraform
- Requisitos
- Instalación y configuración
- Despliegue paso a paso
- Troubleshooting
- Costos estimados
- Mejores prácticas

---

## 🚀 Pasos para Usar Esta Infraestructura

### Paso 1: Preparar el entorno

```bash
cd terraform

# Copiar el archivo de ejemplo
cp terraform.tfvars.example terraform.tfvars

# Editar terraform.tfvars con tus valores (opcional)
# Si dejas los defaults, se creará una VPC nueva
```

### Paso 2: Inicializar Terraform

```bash
terraform init
```

### Paso 3: Validar configuración

```bash
terraform validate
terraform plan
```

### Paso 4: Aplicar cambios

```bash
terraform apply
```

Escribir `yes` cuando Terraform pida confirmación.

### Paso 5: Obtener outputs

```bash
terraform output

# O un output específico:
terraform output alb_dns_name
terraform output instance_public_ips
```

---

## 📊 Arquitectura Creada

```
                     ┌─────────────────────────────┐
                     │   Application Load Balancer  │
                     │    (hola-mundo-alb)         │
                     │   DNS: <alb_dns_name>       │
                     │   Puerto: 80 (HTTP)         │
                     └──────────────┬──────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
         ┌──────▼──────┐     ┌──────▼──────┐     ┌──────▼──────┐
         │   EC2 (us-  │     │   EC2 (us-  │     │   EC2 (us-  │
         │  east-1a)   │     │  east-1b)   │     │  east-1c)   │
         │ Docker Cont │     │ Docker Cont │     │ Docker Cont │
         │ Port 3000   │     │ Port 3000   │     │ Port 3000   │
         └─────────────┘     └─────────────┘     └─────────────┘
                │                   │                   │
         ┌──────▴───────────────────┴───────────────────┴──────┐
         │          VPC (10.0.0.0/16)                          │
         │  ┌────────────────────────────────────────────────┐ │
         │  │   Public Subnets (10.0.1.0/24, etc)           │ │
         │  │   with Internet Gateway                       │ │
         │  └────────────────────────────────────────────────┘ │
         │                 Auto Scaling Group                   │
         │            (Min: 2, Max: 6, Desired: 2)            │
         └──────────────────────────────────────────────────────┘
```

---

## 💰 Costos Estimados

| Recurso | Cantidad | Costo Mensual |
|---------|----------|---------------|
| EC2 (t3.micro) | 2 | ~$12 |
| ALB | 1 | ~$16 |
| Data Transfer | Variable | Variable |
| **TOTAL** | - | **~$30-40/mes** |

---

## 🔒 Seguridad

✅ **Implementado:**
- Security Groups con reglas específicas
- Traffic permitido solo en puertos necesarios (80, 443, 22)
- Subnets públicas con NAT (si se requiere privadas)
- Health checks del ALB
- Auto-restart de contenedores Docker

⚠️ **Para Producción:**
- Usar HTTPS (certificado SSL/TLS)
- Limitar SSH solo a IPs conocidas
- Usar secretos en AWS Secrets Manager
- Implementar CloudWatch para monitoreo
- Usar backend remoto en S3 para estado

---

## 📝 Notas Importantes

1. **Primera ejecución:** Tardará 5-10 minutos en crear todos los recursos.

2. **Cambios en variables:** Edita `terraform.tfvars` y ejecuta `terraform apply` nuevamente.

3. **Destruir infraestructura:** `terraform destroy` (⚠️ ELIMINA TODO)

4. **Monitorear aplicación:**
   - Dashboard AWS Console
   - Target Group Health Status
   - CloudWatch Logs

5. **Logs de Docker:**
   - SSH a la instancia
   - `docker ps` para ver contenedores
   - `docker logs <container_id>` para ver logs

---

## 🔧 Personalización

### Cambiar número de instancias

En `terraform.tfvars`:
```hcl
asg_desired_capacity = 4  # Más instancias
asg_max_size = 10         # Máximo permitido
```

### Cambiar tipo de instancia

En `terraform.tfvars`:
```hcl
instance_type = "t3.small"  # Más potencia
```

### Cambiar puerto del contenedor

En `terraform.tfvars`:
```hcl
container_port = 8080  # Cambiar puerto
```

### Cambiar repositorio GitHub

En `terraform.tfvars`:
```hcl
github_repo_url = "https://github.com/tu-usuario/tu-repo.git"
```

---

## ✅ Verificación Post-Deployment

1. **Ver instancias creadas:**
   ```bash
   terraform output instance_ids
   terraform output instance_public_ips
   ```

2. **Probar la aplicación:**
   ```bash
   curl http://$(terraform output -raw alb_dns_name)
   ```

3. **Verificar Health Status:**
   - AWS Console → EC2 → Load Balancers
   - Ver Target Group → Targets (deben estar en "Healthy")

4. **Logs de despliegue:**
   - SSH a la instancia y revisar `/var/log/cloud-init-output.log`

---

## ❓ Preguntas Frecuentes

**P: ¿Puedo usar AWS Academy?**
R: Sí, pero algunos recursos pueden tener limitaciones. Verifica permisos IAM.

**P: ¿Necesito un Key Pair de EC2?**
R: Para SSH sí. Crea uno en AWS Console → EC2 → Key Pairs.

**P: ¿Cómo escalo automáticamente?**
R: El ASG ya está configurado. Usa métricas de CloudWatch para triggers.

**P: ¿Puedo usar HTTPS?**
R: Sí, agrega un certificado ACM y actualiza el listener del ALB.

**P: ¿Qué pasa si falla el deployment?**
R: Revisa los logs: `terraform plan` identifica errores. Destruye con `terraform destroy` y reinicia.

---

**¡Listo para desplegar tu infraestructura en AWS!** 🎉
