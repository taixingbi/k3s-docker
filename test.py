import retrieve_chunks

retrieve_chunks.configure(
    env="dev",
    qdrant_url="http://192.168.86.173:6333",
    embedding_url="http://192.168.86.173:8001",
    embedding_model="BAAI/bge-m3",
    collection_name="taixing_knowledge",
)
chunks = retrieve_chunks.query_chunks("who is taixing?", k=3)
print(chunks)
