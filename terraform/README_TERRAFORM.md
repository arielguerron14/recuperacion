# Terraform AWS Infrastructure Deployment

## Overview

Este proyecto contiene la configuración completa de Terraform para desplegar una infraestructura profesional en AWS que incluye:

- **VPC** con subnets públicas en múltiples zonas de disponibilidad
- **Security Groups** para ALB e instancias EC2
- **Application Load Balancer (ALB)** con Target Group
- **Auto Scaling Group** con Launch Template
- **EC2 Instances** con Docker instalado
- **Docker Container** ejecutando desde un repositorio de GitHub

## Estructura de Archivos

```
terraform/
├── main_complete.tf                 # Recursos principales (VPC, SG, ALB, ASG, LT)
├── variables_complete.tf            # Definición de variables de entrada
├── outputs_complete.tf              # Definición de outputs
├── user_data_complete.sh.tpl        # Script de bootstrap para EC2
├── backend.tf                       # Configuración de backend (opcional)
├── terraform.tfvars.example         # Ejemplo de valores de variables
└── README.md                        # Este archivo
```

## Requisitos

- **Terraform** >= 1.5
- **AWS CLI** >= 2.0
- **AWS Account** con permisos suficientes
- **Git** instalado en tu máquina local
- **Docker** instalado localmente (opcional, solo para desarrollo)

## Instalación y Configuración

### 1. Clonar el Repositorio

```bash
git clone https://github.com/arielguerron14/recuperacion.git
cd recuperacion/terraform
```

### 2. Configurar Credenciales AWS

#### Opción A: Configurar AWS CLI

```bash
aws configure
# Ingresa:
# AWS Access Key ID: [tu access key]
# AWS Secret Access Key: [tu secret key]
# Default region: us-east-1
# Default output format: json
```

#### Opción B: Variables de Entorno

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 3. Crear archivo terraform.tfvars (Opcional)

```bash
cp terraform.tfvars.example terraform.tfvars
# Edita terraform.tfvars con tus valores personalizados
```

### 4. Inicializar Terraform

```bash
terraform init
```

Este comando:
- Descarga los plugins necesarios de AWS
- Crea la estructura local de Terraform
- Prepara el estado local

## Variables Disponibles

### Configuración General
- `region`: Región de AWS (default: `us-east-1`)
- `app_name`: Nombre de la aplicación para nombrar recursos (default: `hola-mundo`)

### VPC y Networking
- `vpc_cidr`: Bloque CIDR de la VPC (default: `10.0.0.0/16`)
- `public_subnet_cidrs`: Bloques CIDR para subnets públicas (default: `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]`)
- `availability_zones`: Zonas de disponibilidad (default: `["us-east-1a", "us-east-1b", "us-east-1c"]`)

### EC2
- `instance_type`: Tipo de instancia EC2 (default: `t3.micro`)

### Auto Scaling Group
- `asg_min_size`: Mínimo de instancias (default: `2`)
- `asg_max_size`: Máximo de instancias (default: `6`)
- `asg_desired_capacity`: Cantidad deseada de instancias (default: `2`)

### Docker y Aplicación
- `container_port`: Puerto del contenedor Docker (default: `3000`)
- `github_repo_url`: URL del repositorio GitHub (default: `https://github.com/arielguerron14/recuperacion.git`)

## Deployment

### Plan (Ver cambios sin aplicar)

```bash
terraform plan
```

Este comando muestra los cambios que se van a hacer sin aplicarlos.

### Apply (Crear la infraestructura)

```bash
terraform apply
```

Terraform pedirá confirmación. Escribe `yes` para proceder.

**Tiempo de ejecución:** ~5-10 minutos

### Destroy (Eliminar la infraestructura)

```bash
terraform destroy
```

Terraform pedirá confirmación. Escribe `yes` para eliminar todos los recursos.

## Outputs

Después de ejecutar `terraform apply`, verás outputs como:

```
alb_dns_name = "hola-mundo-1234567890.us-east-1.elb.amazonaws.com"
application_url = "http://hola-mundo-1234567890.us-east-1.elb.amazonaws.com"
instance_ids = ["i-0123456789abcdef0", "i-0987654321fedcba0"]
instance_public_ips = ["203.0.113.10", "203.0.113.11"]
```

Para ver los outputs nuevamente:

```bash
terraform output
```

Para obtener un output específico:

```bash
terraform output alb_dns_name
```

## Acceso a la Aplicación

Después del deployment:

1. **URL de la Aplicación:** `http://<ALB_DNS_NAME>`
   - Obten el DNS del ALB con: `terraform output alb_dns_name`

2. **SSH a Instancias EC2:**
   ```bash
   # Primero, obtén la IP pública
   terraform output instance_public_ips
   
   # Luego conecta (necesitas tu key pair de EC2)
   ssh -i your-key.pem ec2-user@<PUBLIC_IP>
   ```

3. **Ver logs de Docker:**
   ```bash
   # Conecta a la instancia por SSH y ejecuta:
   docker ps
   docker logs hola-mundo-container
   ```

## Troubleshooting

### Error: "No valid credential sources found"

**Solución:** Configura tus credenciales AWS con `aws configure` o variables de entorno.

### Error: "InvalidParameterValue" en Launch Template

**Solución:** Verifica que la AMI `amzn2-ami-hvm-*-x86_64-gp2` exista en tu región.

### Las instancias están "Unhealthy" en el Target Group

**Posibles causas:**
1. Docker no está instalado/corriendo
2. La aplicación no responde en el puerto correcto
3. Security Groups no permiten el tráfico

**Solución:**
- Conecta por SSH a la instancia: `docker ps`
- Verifica los logs: `docker logs hola-mundo-container`
- Revisa Security Groups en la consola AWS

### No puedo conectarme por SSH

**Solución:**
1. Necesitas una key pair de EC2 importada
2. El Security Group debe permitir SSH (puerto 22) desde tu IP

## Costos

Los recursos creados pueden incurrir en costos AWS:

| Recurso | Tipo | Costo Estimado (Mensual) |
|---------|------|--------------------------|
| EC2 Instance (t3.micro) | 2 instancias | ~$12 |
| ALB | 1 Load Balancer | ~$16 |
| Data Transfer | Variable | Variable |

**Total estimado:** ~$30-40/mes (varía según uso)

Para evitar costos, ejecuta `terraform destroy` cuando no lo uses.

## Mejores Prácticas

1. **Usar .tfvars para valores sensibles:**
   ```bash
   terraform apply -var-file="prod.tfvars"
   ```

2. **Backend remoto para estado:**
   - Descomenta la sección de backend.tf
   - Crea un bucket S3 para el estado
   - Usa DynamoDB para locks

3. **Versionamiento de Terraform:**
   ```bash
   terraform version
   ```

4. **Validar configuración:**
   ```bash
   terraform validate
   terraform fmt
   ```

5. **Planificar antes de aplicar:**
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

## Seguridad

- Los Security Groups solo permiten tráfico necesario
- Las instancias se lanzan en subnets públicas con IP pública asignada
- HTTP está permitido (considera HTTPS en producción)
- SSH está permitido desde cualquier IP (en producción, limita esto)

## Soporte y Documentación

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform CLI Commands](https://www.terraform.io/cli/commands)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

## Autor

Ariel Guerrón - [GitHub](https://github.com/arielguerron14)

## Licencia

Este proyecto es de código abierto y está disponible bajo la Licencia MIT.
