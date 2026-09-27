import openai
import pandas as pd
import json
import math

# ==========================================================
# API setting
# ==========================================================

openai.api_key = "HERE SHOULD BE YOUR GPT API"

INPUT_EXCEL = "output_chatgpt_session14.xlsx"
OUTPUT_EXCEL = "Ambiguous_base14.xlsx"

MODEL_NAME = "gpt-4o-2024-11-20"


# ==========================================================
# Load the ALREADY CLEANED data
# ==========================================================

df = pd.read_excel(INPUT_EXCEL)

if "answer" not in df.columns:
    raise ValueError("Excel must contain a column named 'answer'")

if "self_amount" not in df.columns:
    raise ValueError("Excel must contain a column named 'self_amount'")


# ==========================================================
# Prompt
# ==========================================================

def build_prompt(text):
    return f"""
You are a precise text analysis assistant.

Task:

The response below has already been classified as ambiguous because it
contains multiple possible monetary allocations or does not clearly select
one final allocation.

Your task is NOT to determine a final choice.

Instead, extract ALL explicit candidate monetary allocations mentioned in
the response.

The total amount to be divided is $100.

Rules:

1. For every explicit numeric allocation mentioned in the response,
   identify the amount kept by the speaker ("I", "me", or ChatGPT),
   denoted as self_amount.

2. If only the amount given to the other player is stated, calculate:

   self_amount = 100 - other_amount

3. If only the amount kept by the speaker is stated, use that amount directly.

4. A numerical 50/50 split means:

   self_amount = 50

5. Extract ALL candidate allocations mentioned in the text.
   Do not select a preferred or final allocation.

6. Do not infer numerical allocations from qualitative statements such as
   "fair", "selfish", "generous", "reasonable", or "appropriate" unless
   an explicit numerical amount or numerical split is provided.

7. If the same self_amount occurs more than once, include it only once.

8. Sort all extracted self_amount values from smallest to largest.

9. Only include values between 0 and 100.

10. If no explicit numeric allocation can be identified, return an empty list.

Output strictly in JSON and no extra text.

Output format:

{{
    "self_amounts": [number, number, ...]
}}

Examples:

Text:
"I could keep $50 for myself, or alternatively keep $60."

Output:
{{
    "self_amounts": [50, 60]
}}

Text:
"I could give the player $20, or perhaps give the player $50."

Output:
{{
    "self_amounts": [50, 80]
}}

Text:
"A 50/50 split would be reasonable, although I could also keep $70."

Output:
{{
    "self_amounts": [50, 70]
}}

Text:
"A fair allocation or a more selfish allocation could both be reasonable."

Output:
{{
    "self_amounts": []
}}

Text:
\"\"\"{text}\"\"\"
"""


# ==========================================================
# Analyze one ambiguous response
# ==========================================================

def analyze_text(text):

    response = openai.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {
                "role": "system",
                "content": "You are a precise data extraction assistant. Output valid JSON only."
            },
            {
                "role": "user",
                "content": build_prompt(text)
            }
        ],
        temperature=0,
        response_format={"type": "json_object"}
    )

    content = response.choices[0].message.content.strip()

    try:

        result = json.loads(content)

        amounts = result.get("self_amounts", [])

        # Make sure output is a list
        if not isinstance(amounts, list):
            return []

        cleaned_amounts = []

        for x in amounts:

            try:
                value = float(x)

                if 0 <= value <= 100:
                    cleaned_amounts.append(value)

            except (ValueError, TypeError):
                continue

        # Remove duplicates and sort from smallest to largest
        cleaned_amounts = sorted(set(cleaned_amounts))

        return cleaned_amounts

    except json.JSONDecodeError:

        print("JSON error. Raw response:")
        print(content)

        return []


# ==========================================================
# Identify ONLY previously ambiguous observations
# ==========================================================

ambiguous_mask = (
    df["self_amount"]
    .astype(str)
    .str.strip()
    .str.lower()
    .eq("ambiguous")
)

ambiguous_indices = df.index[ambiguous_mask]

print("Total observations:", len(df))
print("Ambiguous observations:", len(ambiguous_indices))


# ==========================================================
# Extract candidate allocations ONLY for ambiguous rows
# ==========================================================

candidate_results = {}

for count, idx in enumerate(ambiguous_indices, start=1):

    raw_text = df.at[idx, "answer"]

    # Empty answer
    if (
        raw_text is None
        or (isinstance(raw_text, float) and math.isnan(raw_text))
        or str(raw_text).strip() == ""
    ):

        candidate_results[idx] = []

        print(
            f"Ambiguous observation "
            f"{count}/{len(ambiguous_indices)}: empty response"
        )

        continue


    print(
        f"Analyzing ambiguous observation "
        f"{count}/{len(ambiguous_indices)} "
        f"(Excel row {idx + 2})"
    )


    try:

        amounts = analyze_text(str(raw_text))

        candidate_results[idx] = amounts

        print("Extracted self amounts:", amounts)


    except Exception as e:

        print(f"Error at Excel row {idx + 2}: {e}")

        candidate_results[idx] = []


# ==========================================================
# Determine the maximum number of candidates
# ==========================================================

max_candidates = max(
    (len(amounts) for amounts in candidate_results.values()),
    default=0
)

print("\nMaximum number of candidate allocations:", max_candidates)


# ==========================================================
# Create new columns:
# self_amount1, self_amount2, ...
# ==========================================================

for j in range(1, max_candidates + 1):

    column_name = f"self_amount{j}"

    # Only create it if it does not already exist
    if column_name not in df.columns:
        df[column_name] = pd.NA


# ==========================================================
# Put extracted amounts back and replace Ambiguous with mean
# ==========================================================

for idx, amounts in candidate_results.items():

    # Write self_amount1, self_amount2, ...
    for j, amount in enumerate(amounts, start=1):

        if float(amount).is_integer():
            amount = int(amount)

        df.at[idx, f"self_amount{j}"] = amount

    # Replace Ambiguous with the mean of all extracted self_amounts
    if len(amounts) > 0:

        mean_self_amount = sum(amounts) / len(amounts)

        df.at[idx, "self_amount"] = mean_self_amount

        if "other_amount" in df.columns:
            df.at[idx, "other_amount"] = 100 - mean_self_amount


# ==========================================================
# Save
# ==========================================================

df.to_excel(
    OUTPUT_EXCEL,
    index=False
)

print("\nDone.")
print("Output saved to:", OUTPUT_EXCEL)
