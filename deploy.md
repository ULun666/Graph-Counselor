# 建立一個新的 Python 3.12 環境
conda create -n graphcounselor python=3.12 -y
conda activate graphcounselor

# 使用 pip 安裝最新的 PyTorch 和 CUDA 依賴，這次也安裝最新的 vLLM
# 我們使用 pip，因為 vLLM 的版本更迭快，pip 上的版本通常比 conda 更新
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
<!-- pip install torch torchvision -->
pip install vllm --extra-index-url https://download.pytorch.org/whl/cu128

# 安裝 Hugging Face 和其他相關套件
pip install datasets accelerate

# Langchain & openai
pip install langchain langchain-core langchain-community
pip install openai scikit-learn sentence-transformers

# 讓 Conda 從 pytorch 和 nvidia 這兩個 channel 中尋找 faiss-gpu 的相容版本，並自動解析所有相關依賴
conda install -c pytorch -c nvidia faiss-gpu -y

# 安裝論文中剩下的其他套件
pip install jsonlines tiktoken networkx IPython evaluate absl-py rouge_score

# 執行
source scripts/run_7b_only.sh