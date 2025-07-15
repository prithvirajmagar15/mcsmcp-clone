# Use official Python image as base
FROM python:3.12-slim AS builder

WORKDIR /app

# Copy requirements for better layer caching
COPY requirements.txt ./
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/
COPY .env .env

FROM python:3.12-slim AS release

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/src ./src
COPY --from=builder /app/.env .env
COPY requirements.txt .

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PORT=80

CMD ["python", "-m", "src.server"]
