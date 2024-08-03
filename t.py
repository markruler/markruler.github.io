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
