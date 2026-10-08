<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;

class Usuario extends Authenticatable
{
    protected $table = 'usuario';
    protected $primaryKey = 'id_usuario';
    public $timestamps = false;

    protected $fillable = ['nombre', 'correo', 'contrasena', 'rol'];
    protected $hidden = ['contrasena'];

    public function getAuthPassword()
    {
        return $this->contrasena;
    }

    public function getRememberTokenName()
    {
        return null;
    }
}