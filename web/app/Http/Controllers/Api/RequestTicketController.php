<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller; use App\Models\RequestTicket; use Illuminate\Http\Request;
class RequestTicketController extends Controller {
 public function index(){return RequestTicket::with('assignee')->latest()->paginate(15);}
 public function show(RequestTicket $ticket){return $ticket->load(['assignee','comments.user','evidences']);}
 public function update(Request $r, RequestTicket $ticket){$ticket->update($r->validate(['status'=>'sometimes|in:pendiente,en_proceso,resuelta,cerrada','priority'=>'sometimes|in:baja,media,alta,critica','assigned_to'=>'nullable|exists:users,id'])); return response()->json($ticket->fresh('assignee'));}
}
