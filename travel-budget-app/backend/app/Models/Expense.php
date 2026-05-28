<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Expense extends Model
{
    // 一括代入を許可するカラム
    protected $fillable = [
        'trip_id',
        'amount',
        'category',
        'memo',
    ];

    // 1つの支出は1つの旅行に紐付く
    public function trip()
    {
        return $this->belongsTo(Trip::class);
    }
}