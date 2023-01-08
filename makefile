define run_bash_script
    sed -i -e 's/\r$$//' $(1)
	sh $(1)
endef
nothing:
build:
	$(call run_bash_script,./components/preprocessing/build_image.sh)
	$(call run_bash_script,./components/training/build_image.sh)
run: 
	$(call run_bash_script,./components/preprocessing/run_simple_example.sh)
	$(call run_bash_script,./components/training/run_simple_example.sh)
build_minikube:
	$(call run_bash_script,./components/preprocessing/build_image_minikube.sh)
	$(call run_bash_script,./components/training/build_image_minikube.sh)
	
.PHONY: build run build_minikube