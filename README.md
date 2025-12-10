# Proyecto: Hola Mundo - Docker en AWS (Terraform)

Estructura del proyecto:

```
proyecto-hola-mundo/
├── app/
│   ├── server.js
│   ├── package.json
   └── Dockerfile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── user_data.sh.tpl
└── README.md
```

Instrucciones mínimas de despliegue

1. Subir este proyecto a un repositorio público en GitHub (o ajustar `repo_url` a la URL pública del repositorio).

2. Ir a la carpeta `terraform`:

```bash
cd terraform
```

3. Inicializar y aplicar Terraform (reemplazar `repo_url` si no cambiaste el valor por defecto):

```bash
terraform init
terraform apply -var="repo_url=https://github.com/your-username/proyecto-hola-mundo.git"
```

4. Terraform mostrará la salida `alb_dns_name`. Ese es el DNS público del Load Balancer.

Notas importantes
- El `user_data` clona el repositorio público indicado en `var.repo_url` y construye la imagen Docker.
- En AWS Academy algunos recursos pueden estar restringidos; si algo falla, revisa permisos y disponibilidad en tu cuenta de laboratorio.
- Este Terraform evita IAM y usa recursos básicos: Launch Template, Auto Scaling Group y ALB.
