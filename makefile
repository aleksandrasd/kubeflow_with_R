build:
	sh ./components/training/build_image.sh
	sh ./components/preprocessing/build_image.sh
run: 
	sh ./components/preprocessing/run_simple_example.sh
	sh ./components/training/run_simple_example.sh
build_minikube:
	sh ./components/preprocessing/build_image_minikube.sh
	sh ./components/training/build_image_minikube.sh
	
.PHONY: build run build_minikube