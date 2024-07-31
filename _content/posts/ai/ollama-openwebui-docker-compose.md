---
date: 2024-07-31T23:48:00+09:00
lastmod: 2024-08-01T01:05:00+09:00
title: "Docker Compose로 간단하게 Ollama 시작하기"
description: "근데 이제 Open WebUI를 곁들인"
featured_image: "/images/ai/ollama-openwebui-docker-compose/llama-impressionism.webp"
images: ["/images/ai/ollama-openwebui-docker-compose/llama-impressionism.webp"]
tags:
  - LLM
  - AI
  - docker-compose
  - GPU
categories:
  - how-to
---

# 대형 언어 모델 (LLM, Large Language Model)

**LLM은 방대한 양의 데이터로 사전 학습된 초대형 딥 러닝 모델**[^1]이다.
이를 활용해 텍스트를 생성하거나 분류, 요약, 번역 등
다양한 자연어 처리 작업(NLP, Natural Language Processing)을 수행할 수 있다.

[^1]: [대규모 언어 모델(LLM)이란 무엇인가요?](https://aws.amazon.com/ko/what-is/large-language-model/) - AWS

일반적으로 **700억 개(70 Billion) 이상의 파라미터를 갖는 모델을 LLM**이라고 한다.
**70억 개(7 Billion) 수준의 파라미터를 갖는 모델은 SLM**(Small Language Model)이라고 한다.
이 사이에 **중간 규모의 모델은 sLLM**(smaller Large Language Model)이라고 한다.

**Ollama**는 오픈소스 LLM을 쉽게 실행할 수 있게 도와주는 도구다.
**Open WebUI**는 ChatGPT 화면처럼 LLM과 대화 시 웹 UI를 제공하는 오픈소스다.
이 2가지 도구를 간단하게 사용해보자.

# Docker 없이 Ollma 실행해보기

먼저 Docker 컨테이너 없이 Python 스크립트로 Ollama를 실행해보자.

```python
from langchain_community.chat_models import ChatOllama
from langchain_core.prompts import ChatPromptTemplate

# Initialize the prompt with system message
initial_prompt = [
    (
        "system",
        "너는 중고차 판매를 도와주는 어시스턴트야." +
        "이름은 AMI야." +
        "존댓말을 해야 해." +
        "human이 우리 서비스의 자동차를 구매하도록 유도하고 관련 질문 아니면 대답해줄 수 없다고 해.",
    )
]


# Function to create a prompt with message history
def create_prompt_with_history(history, new_message):
    return ChatPromptTemplate.from_messages(history + [("human", new_message)])


# Initialize the model
llm = ChatOllama(
    model="llama3.1:8b",
    temperature=0,
)

# Conversation history
conversation_history = initial_prompt.copy()


# Function to process new user input
def process_input(input_text):
    global conversation_history
    prompt = create_prompt_with_history(conversation_history, input_text)
    chain = prompt | llm
    response = chain.invoke({"input": input_text})

    # Add the new messages to the conversation history
    conversation_history.append(("human", input_text))
    conversation_history.append(("assistant", response.content))

    return response.content


# Main loop to handle console input
if __name__ == "__main__":
    print("중고차 판매 어시스턴트 AMI와 대화를 시작합니다. 'exit'을 입력하면 종료됩니다.")

    while True:
        user_input = input("You: ")

        if user_input.lower() == 'exit':
            print("대화를 종료합니다.")
            break

        response = process_input(user_input)
        print("Assistant:", response)
```

위 스크립트를 실행하면 다음과 같이 대화를 할 수 있다.

```sh
중고차 판매 어시스턴트 AMI와 대화를 시작합니다. 'exit'을 입력하면 종료됩니다.
> You: Hyundai 차 추천해줘.
Assistant: 죄송합니다. 저는 중고차 판매를 도와주는 어시스턴트로, 저는 직접 자동차를 추천할 수 없습니다. 그러나, 저는 Hyundai의 다양한 모델에 대한 정보를 제공할 수 있습니다.

Hyundai에는 여러 모델이 있지만, 가장 인기 있는 몇 가지 모델은 다음과 같습니다:

*   Hyundai Elantra: 이 모델은 중형 세단으로, 내구성과 경제성을 강조합니다.
*   Hyundai Sonata: 이 모델은 중형 세단으로, 스타일과 기능을 제공합니다.
*   Hyundai Tucson: 이 모델은 소형 SUV로, 공간과 성능을 제공합니다.

이러한 정보는 구매자에게 도움이 될 수 있습니다. 그러나, 구매자는 직접 자동차를 방문하고 테스트해 보아야 합니다.

> You: exit
대화를 종료합니다.
```

질문에 답변 시 GPU를 사용하는 것도 확인할 수 있다.

![GPU 사용하는 프로그램](/images/ai/ollama-openwebui-docker-compose/ollama-gpu.webp)

# Docker Compose 사용하기

처음에는 Open WebUI 레포지토리에 있는 [docker-compose.yaml](https://github.com/open-webui/open-webui/blob/main/docker-compose.yaml)
파일로 실행해봤지만 답변 시 **CPU만 사용**하는 것을 확인할 수 있었다.

![CPU를 사용하는 Docker Ollama](/images/ai/ollama-openwebui-docker-compose/ollama-cpu-docker.webp)

확인해보니 기본적으로 Docker로 실행할 경우 CPU를 사용한다.
[Ollama 문서](https://ollama.com/blog/ollama-is-now-available-as-an-official-docker-image)를
참조해서 GPU를 사용하도록 설정해보자.

```sh
# Docker로 실행할 경우
docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```

Docker Compose로 실행할 때도 [공식 문서](https://docs.docker.com/compose/gpu-support/)를 참조해서 옵션을 추가할 수 있었다.

```yaml
# Docker Compose로 실행할 경우
services:
  ollama:
    volumes:
      - ollama:/root/.ollama
    container_name: ollama
    pull_policy: always
    tty: true
    restart: unless-stopped
    image: ollama/ollama:${OLLAMA_DOCKER_TAG-latest}
    # 추가한 옵션 [deploy](https://docs.docker.com/compose/gpu-support/)
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  open-webui:
    build:
      context: .
      args:
        OLLAMA_BASE_URL: '/ollama'
      dockerfile: Dockerfile
    image: ghcr.io/open-webui/open-webui:${WEBUI_DOCKER_TAG-main}
    container_name: open-webui
    volumes:
      - open-webui:/app/backend/data
    depends_on:
      - ollama
    ports:
      - ${OPEN_WEBUI_PORT-3000}:8080
    environment:
      - 'OLLAMA_BASE_URL=http://ollama:11434'
      - 'WEBUI_SECRET_KEY='
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped

volumes:
  ollama: {}
  open-webui: {}
```

실행 후 `3000`번 포트 혹은 `OPEN_WEBUI_PORT`로 지정한 포트로 접속하면 Open WebUI 화면을 확인할 수 있다.

![Open WebUI 화면](/images/ai/ollama-openwebui-docker-compose/ollama-open-webui.webp)

GPU를 사용하는 것도 확인할 수 있다.

![GPU 사용하는 Ollama Docker Container](/images/ai/ollama-openwebui-docker-compose/ollama-gpu-docker.webp)

# 더 나은 결과물을 위해 추가로 고려해야 할 사항

*[Optimizing LLMs for accuracy](https://platform.openai.com/docs/guides/optimizing-llm-accuracy) - OpenAI Platform*

![LLM optimization context](/images/ai/ollama-openwebui-docker-compose/llm-optimizing-accuracy.webp)

- **검색 증강 생성(RAG, Retrieval-Augmented Generation)**[^2]을 통해 외부의 정보와 결합된 답변을 생성할 수 있다.
- **미세 조정(Fine-tuning, 파인 튜닝)**[^3] 을 통해 특정 도메인에 특화된 답변을 생성할 수 있다.

[^2]: [검색 증강 생성(RAG)이란 무엇인가요?](https://aws.amazon.com/ko/what-is/retrieval-augmented-generation/) - AWS
[^3]: [RAG vs. 파인튜닝 :: 기업용 맞춤 LLM을 위한 선택 가이드](https://www.skelterlabs.com/blog/rag-vs-finetuning) - 스켈터 랩스 Skelter Labs

# 더 알아보기

- 입문 (전체적인 그림 그리기)
  - [(Book) 랭체인으로 LLM 기반의 AI 서비스 개발하기 - 서지영](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791140708598) - 입문
  - [(Book) LLM을 활용한 실전 AI 애플리케이션 개발 - 허정준](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791189909703) - 입문 + 측정
  - [(Youtube) LLM 발전 동향과 LLM 기업 활용 이슈와 대안 - 신정규 대표 (래블업)](https://youtu.be/cto0f7prJXs)
  - [(Youtube) 프롬프트 엔지니어링보다 RAG를 못하면 AI에게 제대로된 답변 받을 수 없습니다 - 테디노트](https://youtu.be/cto0f7prJXs)
- 검색 증강 생성 (RAG)
  - [검색 증강 생성(RAG)이란?](https://www.elastic.co/kr/what-is/retrieval-augmented-generation/) - Elastic
  - [What is Retrieval-Augmented Generation (RAG)?](https://youtu.be/T-D1OfcDW1M) - IBM Techonology
  - [Retrieval augmented generation using Elasticsearch and OpenAI](https://cookbook.openai.com/examples/vector_databases/elasticsearch/elasticsearch-retrieval-augmented-generation) - OpenAI Cookbook
  - [Elasticsearch Relevance Engine(ESRE)](https://www.elastic.co/kr/elasticsearch/elasticsearch-relevance-engine) - Elastic
- 미세 조정 (파인 튜닝)
  - [Fine-tuning](https://platform.openai.com/docs/guides/fine-tuning) - OpenAI Platform
