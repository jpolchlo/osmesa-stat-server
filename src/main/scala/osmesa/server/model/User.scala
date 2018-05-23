package osmesa.server.model

import doobie._
import doobie.implicits._
import cats.effect._
import io.circe._
import io.circe.generic.semiauto._


case class User(
  id: Int,
  name: String
)


object User {

  implicit val userDecoder: Decoder[User] = deriveDecoder
  implicit val userEncoder: Encoder[User] = deriveEncoder

  private val selectF = fr"""
      SELECT
        id, name
      FROM
        users
    """

  def byId(id: Int)(implicit xa: Transactor[IO]): fs2.Stream[IO, User] =
    (selectF ++ fr"WHERE id = $id")
      .query[User]
      .stream
      .transact(xa)

}

