<?php

// Simple internal test service.
// Responds with a static-ish JSON payload to prove Deno can call PHP internally.
header('Content-Type: application/json; charset=utf-8');
echo json_encode([
    'message' => 'Hello from the internal PHP service!',
    'static' => true,
    'timestamp' => date(DATE_ATOM),
], JSON_PRETTY_PRINT);
