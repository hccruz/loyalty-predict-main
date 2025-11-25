# Define o ambiente Conda
CONDA_ENV_NAME = loyaty-predict

# Define o diretório do ambiente virtual
VENV_DIR = .venv

# Define os diretórios
# ENGINEERING_DIR=
# ANALYTICS_DIR=

# Configura o ambiente virtual

.PHONY: setup
setup:
	rm -rf $(VENV_DIR)
	@echo 'Criando o ambiente virtual...'
	python3 -m venv $(VENV_DIR)
	@echo 'Ativando ambiente virtual e instalando dependências...'
	. $(VENV_DIR)/bin/activate && \
	pip install pipreqs && \
	rm -f requirements.txt && \
	pipreqs src/ --force --savepath requirements.txt && \
	pip install -r requirements.txt

# Executa os scripts
.PHONY: run
run:
	@echo 'Ativando o ambiente virtual...'
	. $(VENV_DIR)/bin/activate && \
	cd src/engineering && \
	python get_data.py && \
	cd ../analytics && \
	python pipeline_analytics.py

all: setup run
	@echo 'Processo concluído.'