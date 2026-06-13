<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title inertia>ParkirGo - Dashboard Admin</title>
    <meta name="description"
        content="ParkirGo adalah aplikasi manajemen parkir digital untuk mencatat kendaraan masuk/keluar pada parkir tepi jalan.">
    <meta name="keywords"
        content="ParkirGo, manajemen parkir, aplikasi parkir, retribusi parkir, parkir digital">
    <meta name="author" content="ParkirGo">

    <!-- Social Media Meta Tags -->
    <meta property="og:title" content="ParkirGo - Dashboard Admin">
    <meta property="og:description"
        content="Aplikasi manajemen parkir digital untuk mencatat kendaraan masuk/keluar pada parkir tepi jalan.">
    <meta property="og:image" content="{{ URL::asset('image/android-chrome-512x512.png') }}">
    <meta property="og:url" content="{{ url()->current() }}">
    <meta name="twitter:card" content="summary_large_image">

    <!-- App favicon -->
    <link rel="icon" type="image/png" sizes="16x16" href="{{ URL::asset('image/favicon-16x16.png') }}">
    <link rel="icon" type="image/png" sizes="32x32" href="{{ URL::asset('image/favicon-32x32.png') }}">
    <link rel="apple-touch-icon" sizes="180x180" href="{{ URL::asset('image/apple-touch-icon.png') }}">
    <link rel="shortcut icon" href="{{ URL::asset('image/favicon.ico') }}">
    <link rel="manifest" href="{{ URL::asset('image/site.webmanifest') }}">
    <meta name="theme-color" content="#ffffff">

    <!-- Scripts -->
    @routes
    @vite(['resources/js/app.js', "resources/js/Pages/{$page['component']}.vue"])
    @inertiaHead
</head>

<body>
    @inertia
</body>

</html>
