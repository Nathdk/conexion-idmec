<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Egreso extends Model
{
    protected $table = 'egreso';
    protected $primaryKey = 'id_egreso';
    public $timestamps = false;

    protected $fillable = ['monto', 'fecha', 'concepto', 'comprobante', 'id_tesorero'];
}