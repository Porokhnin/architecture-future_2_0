# Задание 2. Интеграция с CI/CD и удалённым хранением состояния

Данный проект реализует универсальный переиспользуемый модуль для развертывания виртуальных машин в Yandex Cloud с изоляцией сред (`dev`, `stage`, `prod`), удаленным хранением состояния в в S3-совместимом хранилище Yandex Object Storage и автоматизацией CI/CDчерез GitHub Actions.

## Используемые технологии
* **Terraform** — управление инфраструктурой как кодом (IaC).
* **Yandex Object Storage** — S3 бэкенд для хранения стейта.
* **GitHub Actions** — CI/CD автоматизация.

## Архитектура проекта

```text
Task2Advanced/
  ├── modules/
  │   └── vm/
  │       ├── main.tf        # main
  │       ├── variables.tf   # Входные параметры
  │       └── outputs.tf     # Выходные данные модуля 
  └── envs/
      ├── dev/
      ├── stage/
      └── prod/
          ├── main.tf        # Корневой вызов модуля 
          ├── terraform.tfvars  # Параметры вычислительных ресурсов среды
          └── backend.tfvars    # Настройки S3-бэкенда для среды
```

---

## 1. Универсальный модуль ВМ (`modules/vm`)

Модуль полностью автономен и не содержит захардкоженных параметров окружений. Он динамически запрашивает актуальный образ Ubuntu 22.04 LTS и собирает инфраструктуру из двух раздельных ресурсов (`yandex_compute_disk` и `yandex_compute_instance`).

### Входные параметры (Variables)
Модуль принимает строго 5 конфигурационных параметров:
1. `cores` (`number`) — Количество ядер процессора (по умолчанию: `2`).
2. `memory` (`number`) — Объём оперативной памяти RAM в ГБ (по умолчанию: `2`).
3. `boot_disk_size` (`number`) — Размер подключаемого диска в ГБ (по умолчанию: `4`).
4. `subnet_id` (`string`) — Идентификатор подсети (Subnet ID).
5. `ssh_key` (`string`) — Публичный SSH-ключ (содержимое `.pub` файла).

### Выходные данные (Outputs)
* `instance_id` — Уникальный ID виртуальной машины.
* `external_ip` — Публичный IP-адрес ВМ (обработан через индекс `[0]`).
* `disk_id` — ID подключаемого загрузочного диска.

---

## 2. Удалённое хранение состояния (S3 Backend)

Состояние (State) каждого окружения изолировано и хранится в **Yandex Object Storage**. Настройки бэкенда вынесены в файлы `backend.tfvars` внутри папок окружений. Они используют флаги совместимости для корректной работы S3:

```hcl
endpoints = { s3 = "https://yandexcloud.net" }
bucket                      = "architecture-future-2.0"
region                      = "ru-central1"
key                         = "envs/dev/terraform.tfstate" # Свой путь для каждой среды
skip_region_validation      = true
skip_credentials_validation = true
skip_requesting_account_id  = true
use_path_style              = true
```

---

## 3. Автоматизация CI/CD (GitHub Actions)

Пайплайн описан в файле `.github/workflows/terraform.yml` и разделен на две логические стадии (Jobs).

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

### Ручной запуск (Workflow Dispatch)
Перейдите во вкладку **Actions** -> **Terraform CI/CD** -> **Run workflow**, выберите ветку и укажите целевую среду (`dev`, `stage` или `prod`). Пайплайн автоматически переключит `TF_ROOT` на нужный каталог.

---

## 4. Локальный запуск (Альтернативный вариант)

Если вам необходимо проверить работу модуля локально из терминала:
1. Перейдите в каталог окружения: `cd envs/dev/`
2. Инициализируйте бэкенд: `terraform init -backend-config="backend.tfvars"`
3. Проверьте план изменений: `terraform plan -var-file="terraform.tfvars"`
4. Примените конфигурацию: `terraform apply -var-file="terraform.tfvars"`
