<?php defined('BASEPATH') or exit('No direct script access allowed');

class AiService
{
    protected $provider;
    protected $model;
    protected $apiKey;

    public function __construct()
    {
        $this->provider = is_settings('ai_provider');
        if ($this->provider == 'gemini') {
            $this->model = is_settings('gemini_model');
            $this->apiKey = is_settings('gemini_api_key');
        } else if ($this->provider == 'openai') {
            $this->model = is_settings('openai_model');
            $this->apiKey = is_settings('openai_api_key');
        }
    }

    public function generate($params)
    {
        if ($this->model && $this->apiKey) {
            $quiz_type = $params['quiz_type'] ?? 0;
            $language = $params['language'] ?? '';
            $category = $params['category'] ?? '';
            $subcategory = $params['subcategory'] ?? '';
            $difficulty = $params['level'] ?? 0;
            $questionTypes = $params['question_type'] ?? 1;
            $answerTypes = $params['answer_type'] ?? '';
            $numberOfQuestions = $params['total_questions'] ?? 1;
            $contest = $params['contest'] ?? '';
            $exam = $params['exam'] ?? '';
            $detail = $params['detail'] ?? '';
            $marks = $params['marks'] ?? 0;
            $prompt = $this->buildPrompt($quiz_type, $language, $category, $subcategory, $difficulty, $numberOfQuestions, $questionTypes, $answerTypes, $contest, $exam, $detail, $marks);
            switch (strtolower($this->provider)) {
                case 'gemini':
                    return $this->callGemini($prompt);

                case 'openai':
                    return $this->callOpenAI($prompt);

                default:
                    log_message('error', 'Invalid AI provider specified');
                    $result = [
                        'error'     => true,
                        'msg'       => 'Invalid AI provider specified',
                    ];
                    return $result;
            }
        } else {
            log_message('error', 'Check Model & ApiKey');
            $result = [
                'error'     => true,
                'msg'       => 'Check Model & ApiKey',
            ];
            return $result;
        }
    }

    private function callGemini($prompt)
    {
        $payload = [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $prompt],
                    ],
                ],
            ],
            'generationConfig' => [
                'responseMimeType' => 'application/json',
                'responseSchema' => $this->getResponseSchema()
            ],
        ];

        $headers = [
            'x-goog-api-key: ' . $this->apiKey,
            'Content-Type: application/json',
        ];

        $apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/{$this->model}:generateContent";

        $response = $this->sendCurlRequest($apiUrl, $payload, $headers);
        if (!$response['error']) {

            $data = json_decode($response['response'], true);

            if (empty($data['candidates'][0]['content']['parts'][0]['text'])) {
                log_message('error', 'Invalid Gemini response: ' . $response);
                return ['error' => true, 'msg' =>  'Invalid Gemini response: ' . $response];
            }

            $content = $data['candidates'][0]['content']['parts'][0]['text'];
            log_message('error', 'contentdata: ' .  json_encode($content));

            return $content;
        } else {
            $result = [
                'error'     => true,
                'msg'       => $response['msg'],
                'response'  => $response,
            ];

            return $result;
        }
    }

    private function callOpenAI($prompt)
    {
        $payload = [
            'model' => $this->model,
            'messages' => [
                ['role' => 'user', 'content' => $prompt],
            ],
            'temperature' => 0.7,
        ];

        $headers = [
            'Authorization: Bearer ' . $this->apiKey,
            'Content-Type: application/json',
        ];

        $apiUrl = 'https://api.openai.com/v1/chat/completions';
        $response = $this->sendCurlRequest($apiUrl, $payload, $headers);
        if (!$response['error']) {
            $data = json_decode($response['response'], true);

            if (empty($data['choices'][0]['message']['content'])) {
                log_message('error', 'Invalid OpenAI response: ' . $response);
                return ['error' => true, 'msg' =>  'Invalid OpenAI response: ' . $response];
            }

            $content = $data['choices'][0]['message']['content'];
            $contentdata = json_decode($content, true);
            log_message('error', 'contentdata: ' .  json_encode($contentdata['questions']));

            return $contentdata['questions'];
        } else {
            $result = [
                'error'     => true,
                'msg'       => $response['msg'],
                'response'  => $response,
            ];

            return $result;
        }
    }

    private function sendCurlRequest($url, $payload, $headers)
    {
        try {
            $ch = curl_init($url);
            curl_setopt_array($ch, [
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_POST => true,
                CURLOPT_HTTPHEADER => $headers,
                CURLOPT_POSTFIELDS => json_encode($payload),
                CURLOPT_TIMEOUT => 600,
                CURLOPT_BUFFERSIZE => 128000,
            ]);
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            curl_close($ch);

            $result = [
                'error'     => false,
                'http_code' => $httpCode,
                'msg'       => 'OK',
                'response'  => $response,
            ];

            if ($error) {
                $msg = "cURL Error: $error";
                log_message('error', $msg);

                $decoded = json_decode($error, true);
                $errorMsg = $decoded['error']['message'] ?? "HTTP Error ($httpCode)";

                $result['error'] = true;
                $result['msg'] = $errorMsg;
                $result['response'] = $error;
            } elseif ($httpCode < 200 || $httpCode >= 300) {
                $decoded = json_decode($response, true);
                $errorMsg = $decoded['error']['message'] ?? "HTTP Error ($httpCode)";
                if ($httpCode === 400) {
                    $result = [
                        'error'     => true,
                        'msg'       => "Invalid request or model name.",
                        'http_code' => $httpCode,
                        'response'  => $response,
                    ];
                } else if ($httpCode === 401) {
                    return [
                        'error'     => true,
                        'msg'       => "Invalid API key",
                        'http_code' => $httpCode,
                        'response'  => $response,
                    ];
                } else if ($httpCode === 403) {
                    $result = [
                        'error'     => true,
                        'msg'       => "Invalid or unauthorized API key.",
                        'http_code' => $httpCode,
                        'response'  => $response,
                    ];
                } else if ($httpCode === 404) {
                    $result = [
                        'error'     => true,
                        'msg'       => "Check Model not found.",
                        'http_code' => $httpCode,
                        'response'  => $response,
                    ];
                } else {
                    $result = [
                        'error'     => true,
                        'http_code' => $httpCode,
                        'msg'       => $errorMsg,
                        'response'  => $response,
                    ];
                }
                log_message('error', "HTTP Error ($httpCode): $errorMsg");
            }

            return $result;
        } catch (Exception $e) {
            log_message('error', "exception : ($e)");
            $result = [
                'error'     => true,
                'msg'       => $e->getMessage(),
                'response'  => $e,
            ];
            return $result;
        }
    }

    private function getResponseSchema()
    {
        return [
            'type' => 'ARRAY',
            'items' => [
                'type' => 'OBJECT',
                'properties' => [
                    'question' => ['type' => 'STRING'],
                    'options' => [
                        'type' => 'OBJECT',
                        'properties' => [
                            'a' => ['type' => 'STRING'],
                            'b' => ['type' => 'STRING'],
                            'c' => ['type' => 'STRING'],
                            'd' => ['type' => 'STRING'],
                            'e' => ['type' => 'STRING'],
                        ],
                    ],
                    'correctAnswer' => ['type' => 'STRING'],
                    'note' => ['type' => 'STRING'],

                ],
                'propertyOrdering' => ['question', 'options', 'correctAnswer'],
                'required' => ['question', 'options', 'correctAnswer'],
            ],
        ];
    }

    private function buildPrompt($quiz_type, $language, $category, $subcategory, $difficulty, $numberOfQuestions, $questionTypes, $answerTypes, $contest, $exam, $detail, $marks)
    {
        $difficultyText = '';
        if (!empty($difficulty)) {
            // convert numeric difficulty into text
            switch ($difficulty) {
                case 1:
                    $difficultyText = 'easy';
                    break;
                case 2:
                    $difficultyText = 'medium';
                    break;
                case 3:
                    $difficultyText = 'hard';
                    break;
                default:
                    $difficultyText = 'mixed difficulty';
                    break;
            }
        }

        $prompt = "Generate {$numberOfQuestions} {$difficultyText} level quiz questions in {$language} language. — no more, no less , exact {$numberOfQuestions} questions.\n";

        $prompt .= "The questions should be about the category '{$category}'.";
        if ($subcategory) {
            $prompt .= " and Include questions specifically on the topic of subcategory '{$subcategory}' as well.";
        }
        $prompt .= "\n";

        if (in_array($quiz_type, [1, 6, 7, 8])) {
            if ($questionTypes == 1) {
                $prompt .= "\nEach question type should be options.\n";
                if (is_option_e_mode_enabled()) {
                    $prompt .= "must provide 5 options labeled a, b, c, d, e.\n";
                } else {
                    $prompt .= "must provide 4 options labeled a, b, c, d.\n";
                }
            } else if ($questionTypes == 2) {
                $prompt .= "\nEach question type should be true_false.\n";
                $prompt .= "must provide only 2 options: a) True, b) False. option value must be in language wise\n";
            }
        }

        switch ($quiz_type) {
            case 1:
                $prompt .= "Category-based quiz.\n";
                $prompt .= "Include a 'answer' field with the correct option letter.\n";
                $prompt .= "Include a 'note' field with the short description about question, not include 'answer' string in notes (e.g answer contain 1 then not contain string 1 or one).\n";
                break;
            case 3:
                $prompt .= "Short answer quiz.\n";
                $prompt .= "generate question that answer must be more than 1 character and if 'answer' in number then set that number in string (e.g 1 then set one).\n";
                $prompt .= "Each question should have a direct string answer in the 'answer' field.\n";
                $prompt .= "no need to set options , set blank value\n";
                break;
            case 6:
                $prompt .= "Advanced quiz with answer types.\n";
                if ($answerTypes == 1) {
                    $prompt .= "\nEach answer type should be multiselect.\n";
                    $prompt .= "question should be that have multiple answer.\n";
                    $prompt .= "'answer' should be multiple correct option letters (e.g. a,c).\n";
                } else if ($answerTypes == 2) {
                    $prompt .= "Generate sequence-type questions where the answer requires arranging the given options in the correct order.\n";
                    $prompt .= "Each question must include:\n";
                    $prompt .= "- 'question': a sentence asking the user to arrange or order something.\n";
                    $prompt .= "- 'options': an object containing labeled options (a, b, c, d) with text values.\n";
                    $prompt .= "- 'answer': the correct sequence of option letters in order, separated by commas (e.g. 'b,a,c,d').\n";
                    $prompt .= "Do NOT give a single letter as the answer. Always provide a full ordered sequence of letters (like 'b,a,c,d').\n";
                    $prompt .= json_encode([
                        'questions' => [
                            [
                                'question' => 'string',
                                'options' => [
                                    'a' => 'Option A text',
                                    'b' => 'Option B text',
                                    'c' => 'Option C text',
                                    'd' => 'Option D text',
                                    'e' => 'Option E text'
                                ],
                                'correctAnswer' => 'a,b,c,d,e',
                                'note' => 'string'
                            ]
                        ]
                    ], JSON_PRETTY_PRINT);
                }
                $prompt .= "Include a 'note' field with the short description about question,  not include 'answer' string in notes.\n";
                break;

            case 7:
                $prompt .= "Contest-based quiz.\n";
                $prompt .= "Get questions related to contest '{$contest}' and short detail of this contest: '{$detail}'.\n";
                $prompt .= "Include a 'answer' field with the correct option letter.\n";
                $prompt .= "Include a 'note' field with the short description about question,  not include 'answer' string in notes.\n";
                break;
            case 8:
                $prompt .= "Exam-based quiz.\n";
                $prompt .= "Get '{$marks}' marks questions related to exam '{$exam}' and short detail of this exam: '{$detail}'.\n";
                $prompt .= "Include a 'answer' field with the correct option letter.\n";
                break;
        }

        $prompt .= "\nReturn ONLY valid JSON with this structure (no markdown, no explanation):\n";
        $prompt .= json_encode([
            'questions' => [
                [
                    'question' => 'string',
                    'options' => [
                        'a' => 'Option A text',
                        'b' => 'Option B text',
                        'c' => 'Option C text',
                        'd' => 'Option D text',
                        'e' => 'Option E text'
                    ],
                    'correctAnswer' => 'a',
                    'note' => 'string'
                ]
            ]
        ], JSON_PRETTY_PRINT);

        return $prompt;
    }
}
