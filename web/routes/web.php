<?php

use App\Http\Controllers\AdminController;
use App\Http\Controllers\StudentController;
use Illuminate\Support\Facades\Route;
Route::redirect('/', '/admin');
Route::middleware('guest')->group(function(){ Route::get('/login',[AdminController::class,'login'])->name('login'); Route::post('/login',[AdminController::class,'authenticate'])->name('login.store'); });
Route::middleware('auth')->prefix('admin')->group(function(){ Route::get('/',[AdminController::class,'dashboard'])->name('dashboard'); Route::get('/solicitudes',[AdminController::class,'index'])->name('tickets.index'); Route::get('/solicitudes/{ticket}',[AdminController::class,'show'])->name('tickets.show'); Route::patch('/solicitudes/{ticket}',[AdminController::class,'update'])->name('tickets.update'); Route::post('/solicitudes/{ticket}/comentarios',[AdminController::class,'comment'])->name('tickets.comment'); Route::get('/reportes',[AdminController::class,'reports'])->name('reports'); Route::post('/logout',[AdminController::class,'logout'])->name('logout'); });
Route::middleware('auth')->prefix('estudiante')->group(function(){Route::get('/',[StudentController::class,'index'])->name('student.index');Route::get('/solicitudes/nueva',[StudentController::class,'create'])->name('student.create');Route::post('/solicitudes',[StudentController::class,'store'])->name('student.store');Route::get('/solicitudes/{ticket}',[StudentController::class,'show'])->name('student.show');Route::get('/solicitudes/{ticket}/editar',[StudentController::class,'edit'])->name('student.edit');Route::patch('/solicitudes/{ticket}',[StudentController::class,'update'])->name('student.update');Route::delete('/solicitudes/{ticket}',[StudentController::class,'destroy'])->name('student.destroy');});
