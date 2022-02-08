# Prefect flow deployment on Gitlab

## Description

Two different Gitlab CI/CD pipelines for flow registration, covering both script storage and docker storage.

## Usage

To use either of the pipelines create a YAML file with one of the gitlab-ci files depending on what kind of flow storage you are using. For either you will need a Prefect API KEY.

### Script storage

The script storage action is used when you are using prefect's Gitlab storage option.

```yaml
register:
  only:
    refs: 
    - <branch_name>
  image: prefecthq/prefect:0.14.17-python3.7
  variables: 
    KEY: $PREFECT_API_KEY
  before_script:
  - pip install -r requirements.txt
    script:
    - prefect auth login -t $KEY
    - prefect register -p flow.py --project <project_name>
```

#### Inputs

| Name | Description |
|------|-------------|
| branch_name | Target branch to deploy flow ie main. | 
| KEY | Your Prefect API key. |
| before_script | requirements file with the dependecies need to run the flow. |
| project_name | which project is the flow being register under. |

### Docker storage

The docker storage pipeline is used when you are using prefect's docker storage option.

```yaml
register:
  only:
    refs: 
    - <branch name>
  image: $IMAGE_URL
  variables: 
    KEY: $PREFECT_API_KEY
    script:
    - prefect auth login -t $KEY
    - prefect register -p flow.py --project <project_name>
```

#### Inputs

| Name | Description |
|------|-------------|
| branch_name | Target branch to deploy flow ie main. | 
| KEY | Your Prefect API key.|
| image | URL to your image.|
| credentials | Auth info for the registry, only needed for private images.
| project_name | which project is the flow being register under. |

