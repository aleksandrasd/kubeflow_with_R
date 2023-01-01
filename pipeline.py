from kfp.dsl import (
  container_component,
  ContainerSpec,
  Dataset,
  Input,
  pipeline,
  Output,
  Model,
  Metrics
) 
from kfp import compiler

@container_component
def get_and_process_dataset(min_ngrams: int, 
                            max_ngrams: int, 
                            max_tokens: int,
                            dataset: Output[Dataset]):
    return ContainerSpec(
        image='registry.dev.svc.cluster.local:5000/kubeflow_with_r_example/preprocessing',
        command=['Rscript', 'main.R'],
        args=[
          '--min_ngrams', min_ngrams,
          '--max_ngrams', max_ngrams,
          '--max_tokens', max_tokens,
          '--output', dataset.path
        ])
                        
@container_component
def train_and_evaluate(dataset: Input[Dataset], 
                       param_lambda: float,
                       param_alpha: float,
                       param_threshold: float,
                       model: Output[Model],
                       metrics: Output[Metrics]):
    return ContainerSpec(
        image='registry.dev.svc.cluster.local:5000/kubeflow_with_r_example/training',
        command=['Rscript', 'main.R'],
        args=[
          '--input', dataset.path, 
          '--lambda', param_lambda,
          '--alpha', param_alpha,
          '--threshold', param_threshold,
          '--output', model.path, 
          '--metric_pipeline', metrics.path
        ])

@pipeline
def example_r_pipeline(min_ngrams: int = 1, 
                       max_ngrams: int = 2, 
                       max_tokens: int = 300,
                       param_lambda: float = 1,
                       param_alpha: float = 1,
                       param_threshold: float = 0.5):
    data_task = get_and_process_dataset(
      min_ngrams=min_ngrams,
      max_ngrams=max_ngrams,
      max_tokens=max_tokens
    )
    train_and_evaluate(
      dataset=data_task.outputs['dataset'],
      param_lambda=param_lambda,
      param_alpha=param_alpha,
      param_threshold=param_threshold
    )

cmplr = compiler.Compiler()
cmplr.compile(
  pipeline_func=example_r_pipeline, 
  package_path='pipeline.yaml'
)
