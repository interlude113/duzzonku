<?php

return [
    // アクセスを許可するパス
    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    // ローカルとVercelのURLを許可
    'allowed_origins' => [
        'http://localhost:5173',
        'https://duzzonku-eta.vercel.app',
    ],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    // Cookieの送信を許可
    'supports_credentials' => true,
];