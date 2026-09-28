<?php
namespace App\Http\Controllers;
use App\Models\RequestTicket;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
class StudentController extends Controller {
 private function student(){ abort_unless(Auth::user()?->role === 'estudiante',403); }
 private function own(RequestTicket $ticket){$this->student();abort_unless($ticket->student_id===Auth::id(),403);}
 public function index(){ $this->student(); return view('student.index',['tickets'=>Auth::user()->requests()->latest()->paginate(10)]); }
 public function create(){ $this->student(); return view('student.form',['ticket'=>new RequestTicket]); }
 public function store(Request $r){$this->student();$data=$r->validate(['title'=>'required|string|max:150','description'=>'required|string|max:3000','type'=>'required|in:Infraestructura,Soporte tecnológico,Equipamiento,Otro','evidence'=>'nullable|file|max:5120|mimes:jpg,jpeg,png,pdf']);$user=Auth::user();$ticket=$user->requests()->create(['code'=>'CC-'.now()->format('Y').'-'.str_pad((string)(RequestTicket::max('id')+1),3,'0',STR_PAD_LEFT),'title'=>$data['title'],'description'=>$data['description'],'type'=>$data['type'],'student_name'=>$user->name,'student_email'=>$user->email]);if($r->hasFile('evidence')){$file=$r->file('evidence');$ticket->evidences()->create(['path'=>$file->store('evidences','public'),'original_name'=>$file->getClientOriginalName()]);}return redirect()->route('student.show',$ticket)->with('success','Solicitud registrada correctamente.');}
 public function show(RequestTicket $ticket){$this->own($ticket);return view('student.show',['ticket'=>$ticket->load(['comments.user','evidences'])]);}
 public function edit(RequestTicket $ticket){$this->own($ticket);abort_unless($ticket->status==='pendiente',422);return view('student.form',['ticket'=>$ticket]);}
 public function update(Request $r,RequestTicket $ticket){$this->own($ticket);abort_unless($ticket->status==='pendiente',422);$data=$r->validate(['title'=>'required|string|max:150','description'=>'required|string|max:3000','type'=>'required|in:Infraestructura,Soporte tecnológico,Equipamiento,Otro','evidence'=>'nullable|file|max:5120|mimes:jpg,jpeg,png,pdf']);$ticket->update($data);if($r->hasFile('evidence')){$file=$r->file('evidence');$ticket->evidences()->create(['path'=>$file->store('evidences','public'),'original_name'=>$file->getClientOriginalName()]);}return redirect()->route('student.show',$ticket)->with('success','Solicitud actualizada.');}
 public function destroy(RequestTicket $ticket){$this->own($ticket);abort_unless($ticket->status==='pendiente',422);$ticket->delete();return redirect()->route('student.index')->with('success','Solicitud eliminada.');}
}
