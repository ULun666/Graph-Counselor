conda activate graphcounselor


CUDA_VISIBLE_DEVICES=0,1,2,3 python -m vllm.entrypoints.openai.api_server \
    --model ../model/Llama-3.1-70B-Instruct \
    --served-model-name Llama-3.1-70B-Instruct \
    --tensor-parallel-size 4 \
    --port 8070 \
    --host 0.0.0.0\
    --max_model_len 32768\
    --gpu-memory-utilization 0.90 > server1.log 2>&1 &


CUDA_VISIBLE_DEVICES=4,5,6,7 python -m vllm.entrypoints.openai.api_server \
    --model ../model/Qwen2.5-72B-Instruct \
    --served-model-name Qwen2.5-72B-Instruct \
    --tensor-parallel-size 4 \
    --port 8080 \
    --host 0.0.0.0\
    --max_model_len 32768\
    --gpu-memory-utilization 0.90 > server2.log 2>&1 &

sleep 1000 # 

curl -s http://0.0.0.0:8070/v1/completions > /dev/null
if [ $? -ne 0 ]; then
    echo "vllm fails, please check the log"
    exit 1
fi
echo "vllm activates"

curl -s http://0.0.0.0:8080/v1/completions > /dev/null
if [ $? -ne 0 ]; then
    echo "vllm fails, please check the log"
    exit 1
fi
echo "vllm activates"

openai_key="not real"

# Llama-2-13b-chat-hf gemma-2-9b-it Mistral-Nemo-Instruct-2407 Mixtral-8x7B-Instruct-v0.1 Qwen2.5-72B-Instruct Meta-Llama-3.1-70B-Instruct Qwen2.5-7B-Instruct
for gpt_version in Meta-Llama-3.1-70B-Instruct
do
#amazon legal biomedical goodreads dblp maple
    for DATASET in amazon legal biomedical goodreads dblp maple
    do
        if [ "$DATASET" != "maple" ]; then
            RESULT_FILE=Graph-Counselor/results/$gpt_version/plan_compound/llm-Reflexion/half-multiple/2-$DATASET/results.jsonl
            python eval_Llama.py --result_file $RESULT_FILE --dataset $DATASET --model Graph-CoT-$gpt_version --openai_key $openai_key --api_url http://0.0.0.0:8070/v1 >> $gpt_version-counselor_eval.log
            python eval_Qwen.py --result_file $RESULT_FILE --dataset $DATASET --model Graph-CoT-$gpt_version --openai_key $openai_key --api_url http://0.0.0.0:8080/v1 >> $gpt_version-counselor_eval.log
        else
            for DOMAIN in Biology Chemistry Materials_Science Medicine Physics #Biology Chemistry Materials_Science Medicine Physics
            do
                RESULT_FILE=Graph-Counselor/results/$gpt_version/plan_compound/llm-Reflexion/half-multiple/2-maple-$DOMAIN/results.jsonl
                python eval_Llama.py --result_file $RESULT_FILE --dataset $DOMAIN --model Graph-CoT-$gpt_version --openai_key $openai_key --api_url http://0.0.0.0:8070/v1 >> $gpt_version-counselor_eval.log
                python eval_Qwen.py --result_file $RESULT_FILE --dataset $DOMAIN --model Graph-CoT-$gpt_version --openai_key $openai_key --api_url http://0.0.0.0:8080/v1 >> $gpt_version-counselor_eval.log
            done
        fi
    done
done