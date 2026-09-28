<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class RequestTicket extends Model {
 use HasFactory;
 protected $fillable=['code','title','description','type','status','priority','student_name','student_email','student_id','assigned_to','resolved_at'];
 protected $casts=['resolved_at'=>'datetime'];
 public function assignee(){ return $this->belongsTo(User::class,'assigned_to'); }
 public function comments(){ return $this->hasMany(TicketComment::class); }
 public function student(){ return $this->belongsTo(User::class,'student_id'); }
 public function evidences(){ return $this->hasMany(TicketEvidence::class); }
}
