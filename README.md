# Kubeflow with R

Can kubeflow work with R language?  Certainly. This repo contains example of two step kubeflow pipeline with pipeline steps written in R.
First step is preprocessing - reads data from csv files, splits texts into n-grams. Second step is training - trains elastic net to do sentiment classification.


## kubeflow installation

*Note, I am running kubeflow on PC with 32GM of RAM. WSL (with kubeflow running in it) takes ~15 GB of RAM. Kubeflow itself takes only ~5GB of RAM. Rest of RAM is taken (reserved) by WSL. In other words, you run kubeflow with much less RAM. To learn how to constrain WSL from allocating too much RAM see [Aleksandr Hovhannisyan's post on limiting memory usage in WSL 2](https://www.aleksandrhovhannisyan.com/blog/limiting-memory-usage-in-wsl-2/).*

For running kubeflow on Windows 11, WSL 2 I used the following tools: 
 
* minikube v1.28.0
* kubernetes v1.21.0  
* kustomize v3.2.0
* kubeflow v1.6

Install docker on WSL.

Install minikube on WSL.

Create kubernetes cluster on minikube:
```
minikube start -p kubeflow --kubernetes-version=v1.21.0 --insecure-registry registry.dev.svc.cluster.local:5000
```

Make profile 'kubeflow' a default profile:

```
minikube profile kubeflow
```

Since kubeflow pulls images from container registry, install container registry by following tutorial [Using a Local Registry with Minikube](https://gist.github.com/trisberg/37c97b6cc53def9a3e38be6143786589?permalink_comment_id=4152467). 

Install kustomize, kubeflow using the following guide (pull git repo and execute commands to deploy kubernetes manifests): [kubeflow/manifests v1.6](https://github.com/kubeflow/manifests/tree/v1.6-branch)

Starting kubeflow **for the first time** may take hours until all pods get ready (e.g., images pulled). This is especially with pod `dex` in namespace `auth`.   

## Running on kubeflow

Build and push docker images into container registry:

```
make build_minikube
```

Go to pipelines, press button to create pipeline, select "upload file", choose file `pipeline.yaml` from this repository.

## Running without kubeflow

Build preprocessing and training docker images:

```
make build
```

Run the containers:

```
make run
```

