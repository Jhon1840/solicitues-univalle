<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class TicketComment extends Model { protected $fillable=['request_ticket_id','user_id','body']; public function user(){return $this->belongsTo(User::class);} }
