<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up(): void { Schema::table('request_tickets',function(Blueprint $table){$table->foreignId('student_id')->nullable()->after('student_email')->constrained('users')->nullOnDelete();}); Schema::create('ticket_evidences',function(Blueprint $table){$table->id();$table->foreignId('request_ticket_id')->constrained()->cascadeOnDelete();$table->string('path');$table->string('original_name');$table->timestamps();}); }
 public function down(): void {Schema::dropIfExists('ticket_evidences');Schema::table('request_tickets',fn(Blueprint $table)=>$table->dropConstrainedForeignId('student_id'));}
};
