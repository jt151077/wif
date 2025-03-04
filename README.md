# Workload Identity Federation (WIF)
Simple exmaple showing how one can build and deploy an application in Cloud Run from Github Actions. The build takes place in Cloud Build, and the application is deployed in Cloud Run. All authentication is handled by Cloud IAM and Workload Identity Federation

## Overall architecture

![](img/0.png)


## Project structure
```

.
├── app
│   ├── Dockerfile
│   └── index.html
├── cloudrun.tf
├── config.tf
├── gcr.tf
├── iam.tf
├── README.md
├── terraform.tfvars.json
└── vars.tf

```

## Setup

1. Replace the the project ID. number and default region with your project details under `terraform.tfvars.json`

## Install

1. Run the following command at the root of the folder:
```shell 
$ sudo ./install.sh
$ terraform init
$ terraform plan
$ terraform apply
```

> Note: You may have to run `terraform plan` and `terraform apply` twice if you get errors for serviceaccounts not found

2. Once the Workload Identity Pool is created, and aditional GCP resources, update the `.github/workflows/deploy.yml` with:

```shell
env:
  APP_NAME: 'frontend'
  PROJECT_ID: '<YOUR_PROJECT_ID>'
  PROJECT_NMR: <YOUR_PROJECT_NMR>
  REGION: 'europe-west1'
  REGISTRY_NAME: 'run-image'
```

3. You can now commit your changes to the repository, which will in turn trigger the github action. If everything worked as expected, you should see a green deploy action:

```shell
git add .
git commit -m '<YOUR_COMMIT_MESSAGE>'
git push
```


![](img/1.png)