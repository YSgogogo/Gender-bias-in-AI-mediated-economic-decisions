import openai
import pandas as pd
import json
import math


openai.api_key = "HERE SHOULD BE YOUR GPT API"
INPUT_EXCEL = "chatgpt_answers_session_appropriate_6.xlsx"
OUTPUT_EXCEL = "output_appropriate_6.xlsx"
MODEL_NAME = "gpt-5-mini"

df = pd.read_excel(INPUT_EXCEL)

if "answer" not in df.columns:
    raise ValueError("Excel must contain a column named 'answer'")

df["self_amount"] = ""
df["other_amount"] = ""

# ========== Prompt ==========
def build_prompt(text):
    return f"""
You are a precise text analysis assistant.

Task:
Determine whether the text explicitly proposes monetary allocation schemes.

Rules:
1. Only consider allocation schemes with explicit numeric dollar amounts.
2. If multiple explicit schemes exist:
   - If the text clearly indicates one scheme as the final decision, select it.
   - If no scheme is clearly final and schemes are equally valid, return Ambiguous.
3. If exactly one explicit scheme exists, select it.
4. If no explicit numeric allocation scheme exists, return Ambiguous.
5. Identify:
   - self_amount: the amount kept by the speaker ("I", "me")
   - other_amount: the amount given to the other player (female, male, or unspecified)

Output strictly in JSON, no extra text.

Output format:
{{
  "status": "OK" | "Ambiguous",
  "self_amount": number | null,
  "other_amount": number | null
}}

Text:
\"\"\"{text}\"\"\"
"""


def analyze_text(text):
    response = openai.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {"role": "system", "content": "You must output valid JSON only."},
            {"role": "user", "content": build_prompt(text)}
        ],
        temperature=1
    )

    content = response.choices[0].message.content

    try:
        return json.loads(content)
    except json.JSONDecodeError:
        return {
            "status": "Ambiguous",
            "self_amount": None,
            "other_amount": None
        }


for idx, row in df.iterrows():
    raw_text = row["answer"]

    if raw_text is None or (isinstance(raw_text, float) and math.isnan(raw_text)) or str(raw_text).strip() == "":
        df.at[idx, "self_amount"] = "NULL"
        df.at[idx, "other_amount"] = "NULL"
        continue

    print(f"Analyzing row {idx + 1}/{len(df)}")

    result = analyze_text(str(raw_text))

    if result["status"] == "OK":
        df.at[idx, "self_amount"] = result["self_amount"]
        df.at[idx, "other_amount"] = result["other_amount"]
    else:
        df.at[idx, "self_amount"] = "Ambiguous"
        df.at[idx, "other_amount"] = "Ambiguous"


df.to_excel(OUTPUT_EXCEL, index=False)

print("Done. Output saved to:", OUTPUT_EXCEL)
