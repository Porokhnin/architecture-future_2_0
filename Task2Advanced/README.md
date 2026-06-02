# Автоматизация развертывания инфраструктуры через CI/CD с удаленным стейтом

Этот проект реализует автоматическое развертывание универсального модуля ВМ с использованием удаленного хранения состояния (`terraform.tfstate`) в S3-совместимом хранилище Yandex Object Storage.

Структура:
```
/Task2Advanced/
  ├── .github/
  │   └── workflows/
  │       └── terraform.yml     # CI/CD Пайплайн
  ├── modules/
  │   └── vm/
  │       ├── main.tf           # Код модуля 
  │       ├── variables.tf      # 5 обязательных переменных
  │       └── outputs.tf        # Выходы
  ├── envs/
  │   ├── dev/
  │   │   ├── main.tf           # Вызов модуля
  │   │   ├── variables.tf      # Переменные среды
  │   │   ├── backend.tf        # Конфигурация S3 Бэкенда
  │   │   └── terraform.tfvars  # Параметры dev 
  │   ├── stage/                # Аналогично dev со своими .tfvars и ключом в backend.tf
  │   └── prod/                 # Аналогично dev со своими .tfvars и ключом в backend.tf
  └── README.md       
```

## Используемые технологии
* **Terraform** — управление инфраструктурой как кодом (IaC).
* **Yandex Object Storage** — S3 бэкенд для хранения стейта.
* **GitHub Actions** — CI/CD автоматизация.

## Описание работы Пайплайна (.github/workflows/terraform.yml)

Пайплайн состоит из двух связанных стадий:

1. **Terraform Plan (Запускается на PR и Push):**
   * `terraform init` — инициализирует провайдеров и скачивает файлы состояния из S3.
   * `terraform validate` — проверяет синтаксическую корректность кода.
   * `terraform plan` — формирует изолированный файл изменений `tfplan` и сохраняет его в артефакты сборки.

2. **Terraform Apply (Запускается только на Push в ветку main):**
   * Задействует механизм `environment: production`. Пайплайн останавливается и ждет ручного подтверждения (**Approval**) от администратора в интерфейсе GitHub.
   * После нажатия кнопки «Approve» скачивает ранее созданный файл `tfplan` и безопасно применяет изменения через `terraform apply -auto-approve tfplan`.

## Настройка секретов в GitHub

Для работы пайплайна добавьте следующие секреты в настройках репозитория (`Settings -> Secrets and variables -> Actions`):


| Имя секрета | Описание |
|--- |--- |
| `YC_STORAGE_ACCESS_KEY` | Статический ключ доступа к бакету S3 |
| `YC_STORAGE_SECRET_KEY` | Секретный ключ доступа к бакету S3 |
| `YC_IAM_TOKEN` | Токен авторизации в Yandex Cloud |
| `YC_CLOUD_ID` | ID вашего облака |
| `YC_FOLDER_ID` | ID целевого каталога (каталог dev/stage/prod) |

## Инструкция по локальному тестированию бэкенда

Если вам необходимо проверить работу удаленного бэкенда локально, выполните:
```bash
cd envs/dev/
export AWS_ACCESS_KEY_ID="ваш_ключ"
export AWS_SECRET_ACCESS_KEY="ваш_секрет"
terraform init
terraform plan -var-file=terraform.tfvars
```