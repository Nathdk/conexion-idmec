<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reporte extends Model
{
    protected $table = 'reporte';
    protected $primaryKey = 'id_reporte';
    public $timestamps = false;

    protected $fillable = ['tipo', 'fecha_generacion', 'id_usuario'];
}