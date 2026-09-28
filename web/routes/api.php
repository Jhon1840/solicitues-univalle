<?php
use App\Http\Controllers\Api\RequestTicketController;
use Illuminate\Support\Facades\Route;
Route::apiResource('solicitudes', RequestTicketController::class)->only(['index','show','update']);
