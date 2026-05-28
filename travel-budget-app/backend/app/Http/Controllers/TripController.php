<?php

namespace App\Http\Controllers;

use App\Models\Trip;
use Illuminate\Http\Request;

class TripController extends Controller
{
    // ログインユーザーの旅行一覧を取得
    public function index()
    {
        $trips = auth()->user()->trips()->withCount('expenses')->get();

        return response()->json($trips);
    }

    // 旅行を新規登録
    public function store(Request $request)
    {
        // 入力値のバリデーション
        $request->validate([
            'name' => 'required|string',
            'budget' => 'required|integer',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $trip = auth()->user()->trips()->create($request->all());

        return response()->json($trip, 201);
    }

    // 旅行を削除
    public function destroy(Trip $trip)
    {
        // 他のユーザーの旅行は削除できないように制限
        if ($trip->user_id !== auth()->id()) {
            return response()->json(['message' => '権限がありません'], 403);
        }

        $trip->delete();

        return response()->json(['message' => '削除しました']);
    }
}