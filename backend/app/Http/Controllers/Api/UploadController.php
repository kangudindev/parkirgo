<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class UploadController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'file' => ['required', 'image', 'max:5120'],
            'type' => ['required', 'in:selfie,entry_photo,exit_photo,proof_image'],
        ]);

        $path = $request->file('file')->store("parkirgo/{$data['type']}", 'public');

        return response()->json([
            'path' => $path,
            'url' => asset("storage/{$path}"),
        ]);
    }
}
