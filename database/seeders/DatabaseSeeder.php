<?php

namespace Database\Seeders;

use App\Models\RequestTicket;
use App\Models\TicketComment;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $admin = User::updateOrCreate(
            ['email' => 'admin@campus.edu'],
            ['name' => 'Administrador Campus', 'password' => Hash::make('password'), 'role' => 'administrativo']
        );
        $soporte = User::updateOrCreate(
            ['email' => 'soporte@campus.edu'],
            ['name' => 'María Soporte', 'password' => Hash::make('password'), 'role' => 'administrativo']
        );
        $estudiante = User::updateOrCreate(['email'=>'estudiante@campus.edu'], ['name'=>'Ana Flores','password'=>Hash::make('password'),'role'=>'estudiante']);

        $solicitudes = [
            ['CC-2026-001', 'Iluminación deficiente en aula A-204', 'Infraestructura', 'alta', 'pendiente', 'Ana Flores', $admin, 'Dos luminarias no encienden y dificultan las clases nocturnas.'],
            ['CC-2026-002', 'Proyector sin señal en laboratorio', 'Soporte tecnológico', 'critica', 'en_proceso', 'Carlos Méndez', $soporte, 'El proyector muestra pantalla azul desde el inicio de la clase.'],
            ['CC-2026-003', 'Sillas dañadas en biblioteca', 'Equipamiento', 'media', 'resuelta', 'Lucía Rojas', $admin, 'Cinco sillas presentan respaldo flojo en la sala de lectura.'],
            ['CC-2026-004', 'Fuga de agua en baño del bloque B', 'Infraestructura', 'critica', 'en_proceso', 'Diego Paredes', $admin, 'La fuga está cerca de los lavamanos del primer piso.'],
            ['CC-2026-005', 'Acceso intermitente a red Wi-Fi', 'Soporte tecnológico', 'alta', 'pendiente', 'Valeria Cruz', null, 'La conexión se pierde repetidamente en el edificio de ingeniería.'],
            ['CC-2026-006', 'Reposición de marcador para pizarra', 'Equipamiento', 'baja', 'cerrada', 'Miguel Torres', $soporte, 'El aula A-102 no cuenta con marcadores funcionales.'],
        ];

        foreach ($solicitudes as [$code, $title, $type, $priority, $status, $student, $assignedTo, $description]) {
            $ticket = RequestTicket::updateOrCreate(
                ['code' => $code],
                ['title' => $title, 'description' => $description, 'type' => $type, 'priority' => $priority, 'status' => $status, 'student_name' => $student, 'student_email' => str($student)->slug('.').'@estudiante.campus.edu', 'student_id' => $student === 'Ana Flores' ? $estudiante->id : null, 'assigned_to' => $assignedTo?->id, 'resolved_at' => in_array($status, ['resuelta', 'cerrada']) ? now()->subDays(2) : null]
            );
            if ($ticket->comments()->doesntExist()) {
                TicketComment::create(['request_ticket_id' => $ticket->id, 'user_id' => $assignedTo?->id ?? $admin->id, 'body' => $status === 'pendiente' ? 'Solicitud recibida. Será asignada para su atención.' : 'Se revisó la solicitud y se registró la gestión correspondiente.']);
            }
        }
    }
}
