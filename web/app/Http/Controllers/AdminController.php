<?php
namespace App\Http\Controllers;
use App\Models\RequestTicket;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
class AdminController extends Controller {
 public function login(){ return view('auth.login'); }
 public function authenticate(Request $r){ $data=$r->validate(['email'=>'required|email','password'=>'required']); if(Auth::attempt($data,$r->boolean('remember'))){$r->session()->regenerate(); return Auth::user()->role === 'estudiante' ? redirect()->route('student.index') : redirect()->route('dashboard');} return back()->withErrors(['email'=>'Credenciales no válidas.'])->onlyInput('email'); }
 public function logout(Request $r){Auth::logout();$r->session()->invalidate();$r->session()->regenerateToken();return redirect()->route('login');}
 private function authorizeAdmin(){ abort_unless(Auth::user()?->role === 'administrativo',403); }
 public function dashboard(){ $this->authorizeAdmin(); $base=RequestTicket::query(); return view('dashboard',['stats'=>['total'=>$base->count(),'pending'=>(clone $base)->where('status','pendiente')->count(),'progress'=>(clone $base)->where('status','en_proceso')->count(),'closed'=>(clone $base)->where('status','cerrada')->count()],'recent'=>RequestTicket::with('assignee')->latest()->take(6)->get()]); }
 public function index(Request $r){$this->authorizeAdmin();$q=RequestTicket::with('assignee')->latest(); foreach(['status','priority','type'] as $filter){if($r->$filter)$q->where($filter,$r->$filter);} if($r->search)$q->where(fn($x)=>$x->where('code','ilike','%'.$r->search.'%')->orWhere('title','ilike','%'.$r->search.'%')->orWhere('student_name','ilike','%'.$r->search.'%')); return view('requests.index',['tickets'=>$q->paginate(10)->withQueryString()]);}
 public function show(RequestTicket $ticket){$this->authorizeAdmin();return view('requests.show',['ticket'=>$ticket->load(['assignee','comments.user','evidences']),'admins'=>User::where('role','administrativo')->orderBy('name')->get()]);}
 public function update(Request $r,RequestTicket $ticket){$this->authorizeAdmin();$data=$r->validate(['status'=>'required|in:pendiente,en_proceso,resuelta,cerrada','priority'=>'required|in:baja,media,alta,critica','assigned_to'=>'nullable|exists:users,id']); if(in_array($data['status'],['resuelta','cerrada'])&&!$ticket->resolved_at)$data['resolved_at']=now(); $ticket->update($data);return back()->with('success','Solicitud actualizada correctamente.');}
 public function comment(Request $r,RequestTicket $ticket){$this->authorizeAdmin();$r->validate(['body'=>'required|string|max:2000']);$ticket->comments()->create(['user_id'=>Auth::id(),'body'=>$r->body]);return back()->with('success','Comentario registrado.');}
 public function reports(){$this->authorizeAdmin();return view('reports',['byType'=>RequestTicket::selectRaw('type, count(*) total')->groupBy('type')->orderByDesc('total')->get(),'byPriority'=>RequestTicket::selectRaw('priority, count(*) total')->groupBy('priority')->get(),'recentClosed'=>RequestTicket::whereNotNull('resolved_at')->latest('resolved_at')->take(10)->get()]);}
}
