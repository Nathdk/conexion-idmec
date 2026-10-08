<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ingreso extends Model
{
    protected $table = 'ingreso';
    protected $primaryKey = 'id_ingreso';
    public $timestamps = false;

    protected $fillable = ['monto', 'fecha', 'concepto', 'departamento', 'id_tesorero'];
}